import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:stream_transform/stream_transform.dart';

class VideoPlayerMediaKit extends VideoPlayerPlatform {
  Map<int, Player> players = {};
  Map<int, int> playersHandles = {};

  Map<int, VideoController> controllers = {};
  //workaround to know if the player is initialized
  Map<int, int> durations = {};
  int counter = 0;

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    VideoPlayerPlatform.instance = VideoPlayerMediaKit();

    return;
  }

  void _disposeAllPlayers() {
    for (final int videoPlayerId in players.keys) {
      dispose(videoPlayerId);
    }
    players.clear();
  }

  @override
  Widget buildView(int textureId) {
    // print(controllers[textureId]);
    return Video(
      controller: controllers[textureId]!,

      // height: 1920.0,
      // width: 1080.0,
      // scale: 1.0, // default
      // showControls: false,
    );
  }

  Future<int> getPlayerHandle(int player) async {
    return playersHandles[player]!;
  }

  String? mapToStringList(Map<String, String> map) {
    String list = "";
    map.forEach((key, value) {
      list += "'$key: $value',";
    });
    if (list.isEmpty) {
      return null;
    }
    return list.substring(0, list.length - 1);
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    Player player = Player(
        configuration: const PlayerConfiguration(
            logLevel: MPVLogLevel.trace)); // create a new video controller
    int id = counter++;

    players[id] = player;

    player.setPlaylistMode(PlaylistMode.loop);
    String? refer, userAgent, headersListString;
    refer = dataSource.httpHeaders["Referer"];
    userAgent = dataSource.httpHeaders["User-Agent"];
    headersListString = mapToStringList(dataSource.httpHeaders);
    //print('--http-referrer=' + refer);

    if (refer != null) {
      (player.platform as libmpvPlayer).setProperty("referrer", refer);
    }
    if (userAgent != null) {
      (player.platform as libmpvPlayer).setProperty("user-agent", userAgent);
    }

    if (headersListString != null) {
      (player.platform as libmpvPlayer)
          .setProperty("http-header-fields", headersListString);
    }

    // int id = await player.handle;
    // playersHandles[counter] = id;
    controllers[counter] = await VideoController.create(player.handle);
    // print(dataSource.asset);
    // print(dataSource.uri);
    if (dataSource.sourceType == DataSourceType.asset) {
      player.open(Media(dataSource.asset!), play: false
          // autoStart: _autoplay,
          );
    } else if (dataSource.sourceType == DataSourceType.network) {
      player.open(Media(dataSource.uri!), play: false);
    } else {
      if (!await File.fromUri(Uri.parse(dataSource.uri!)).exists()) {
        throw Exception("${dataSource.uri!} not found ");
      }
      player.open(Media(dataSource.uri!), play: false
          // autoStart: _autoplay,
          );
    }

    return id;
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    return players[textureId]!.platform!.state.position;
  }

  @override
  Future<void> init() async {
    _disposeAllPlayers();

    // DartVLC.initialize();
  }

  @override
  Future<void> pause(int textureId) async {
    return players[textureId]!.pause();
  }

  @override
  Future<void> play(int textureId) async {
    return players[textureId]!.play();
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    return players[textureId]!.seek(position);
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    assert(speed > 0);
    return players[textureId]!.setRate(speed);
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    return players[textureId]!.setVolume(volume * 100);
  }

  @override
  Future<void> dispose(int textureId) async {
    print("disposed player $textureId");
    // players[textureId]!.playbackStream.listen((element) {
    //   print("is playing ${element.isPlaying}");
    // });
    // await players[textureId]!
    //     .playbackStream
    //     .firstWhere((event) => !event.isPlaying);
    pause(textureId);
    players[textureId]!.dispose();
    players.remove(textureId);
    controllers[textureId]!.dispose();
    return;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    Stream<VideoEvent> isCompleted =
        players[textureId]!.streams.completed.map((event) {
      // print("isCompleted $event");

      return VideoEvent(
        eventType: event ? VideoEventType.unknown : VideoEventType.completed,
      );
    });
    Stream<VideoEvent> initializedStream() async* {
      await for (final event in players[textureId]!.streams.duration) {
        // print("duration $event");
        if (event != Duration.zero) {
          if (!durations.containsKey(textureId) ||
              (durations[textureId] ?? 0) != event.inMicroseconds) {
            durations[textureId] = event.inMicroseconds;
            yield VideoEvent(
              eventType: VideoEventType.initialized,
              duration: event,
              size: Size(controllers[textureId]!.rect.value!.width,
                  controllers[textureId]!.rect.value!.height),
              rotationCorrection: 0,
            );

            // yield VideoEvent(
            //   buffered: [
            //     (DurationRange(
            //         Duration.zero,
            //         Duration(
            //             seconds: ((100) *
            //                     players[textureId]!.state.position.inSeconds)
            //                 .round())))
            //   ],
            //   eventType: VideoEventType.bufferingUpdate,
            // );
          }
        }
        yield VideoEvent(
          eventType: VideoEventType.unknown,
        );
      }
    }

    Stream<VideoEvent> buffering =
        players[textureId]!.streams.buffering.map((event) {
      // print("isBuffering $event");
      if (event) {
        return VideoEvent(
          buffered: [
            (DurationRange(
              Duration.zero,
              Duration.zero,
              // Duration(
              //     seconds: ((event / 100) *
              //             players[textureId]!.position.duration!.inSeconds)
              //         .round())
            ))
          ],
          eventType: VideoEventType.bufferingUpdate,
        );
      } else {
        return VideoEvent(eventType: VideoEventType.bufferingEnd);
      }
    });

    return isCompleted.mergeAll([initializedStream(), buffering]);
  }

  /// setLooping (ignored)
  @override
  Future<void> setLooping(int textureId, bool looping) => Future<void>.value();

  /// Sets the audio mode to mix with other sources (ignored)
  @override
  Future<void> setMixWithOthers(bool mixWithOthers) => Future<void>.value();
}
