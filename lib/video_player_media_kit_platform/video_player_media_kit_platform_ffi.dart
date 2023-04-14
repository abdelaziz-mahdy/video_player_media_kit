import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class VideoPlayerMediaKit extends VideoPlayerPlatform {
  VideoPlayerMediaKit({this.logLevel = MPVLogLevel.warn});

  MPVLogLevel logLevel;

  ///`players`: A map that stores the initialized video players. The keys of the map are unique integers assigned to each player, and the values are instances of the Player class.
  Map<int, Player> players = {};

  ///`controllers`: A map that stores the video controllers for each player. The keys are unique integers assigned to each player, and the values are instances of the VideoController class.
  Map<int, VideoController> controllers = {};

  ///`ducontrollersrations`: A map that stores the duration of each video in microseconds for which the player is initialized. The keys are unique integers assigned to each player.
  ///used to know when player is initialized
  Map<int, int> durations = {};

  ///`counter`: An integer that is used to assign unique IDs to each player instance. The IDs are used as keys in the players, and controllers maps.
  int counter = 0;

  ///`streams`: A map that stores the streams controllers for each player.
  Map<int, StreamController<VideoEvent>> streams = {};

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith({MPVLogLevel logLevel = MPVLogLevel.none}) {
    VideoPlayerPlatform.instance = VideoPlayerMediaKit(logLevel: logLevel);

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
        configuration: PlayerConfiguration(
            logLevel: logLevel)); // create a new video controller

    (player.platform as libmpvPlayer).setProperty("demuxer-lavf-o", "protocol_whitelist=[file,tcp,tls,http,https]");

    int id = counter++;
    players[id] = player;
    initStreams(id);
    controllers[id] = await VideoController.create(player.handle);
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

    // print(dataSource.asset);
    // print(dataSource.uri);
    if (dataSource.sourceType == DataSourceType.asset) {
      final assetName = dataSource.asset!;
      final assetUrl =
          assetName.startsWith("asset://") ? assetName : "asset://$assetName";
      player.open(Media(assetUrl), play: false
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

  void initStreams(int textureId) {
    streams[textureId] = StreamController<VideoEvent>();
    players[textureId]!.streams.completed.listen((event) {
      streams[textureId]!.add(VideoEvent(
        eventType: event ? VideoEventType.unknown : VideoEventType.completed,
      ));
    });
    players[textureId]!.streams.duration.listen((event) {
      if (event != Duration.zero) {
        if (!durations.containsKey(textureId) ||
            (durations[textureId] ?? 0) != event.inMicroseconds) {
          durations[textureId] = event.inMicroseconds;
          streams[textureId]!.add(VideoEvent(
            eventType: VideoEventType.initialized,
            duration: event,
            size: Size(controllers[textureId]!.rect.value!.width,
                controllers[textureId]!.rect.value!.height),
            rotationCorrection: 0,
          ));
        }
      }
    });
    players[textureId]!.streams.buffering.listen((event) {
      // print("buffering $event");
      if (event) {
        streams[textureId]!.add(VideoEvent(
          buffered: [
            (DurationRange(
                Duration.zero,
                // Duration.zero,
                Duration(
                    seconds: (players[textureId]!.state.position.inSeconds + 1)
                        .round())))
          ],
          eventType: VideoEventType.bufferingUpdate,
        ));
      } else {
        streams[textureId]!
            .add(VideoEvent(eventType: VideoEventType.bufferingEnd));
      }
    });

    players[textureId]!.streams.error.listen((event) {
      // print("isBuffering $event");

      streams[textureId]!.addError(PlatformException(
        code: event.code.toString(),
        message: event.message,
      ));
    });
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
    // print("disposed player $textureId");
    // players[textureId]!.playbackStream.listen((element) {
    //   print("is playing ${element.isPlaying}");
    // });
    // await players[textureId]!
    //     .playbackStream
    //     .firstWhere((event) => !event.isPlaying);
    pause(textureId);
    players[textureId]!.dispose();
    controllers[textureId]!.dispose();
    streams[textureId]!.close();
    players.remove(textureId);
    controllers.remove(textureId);
    streams.remove(textureId);
    return;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return streams[textureId]!.stream;
  }

  /// setLooping (ignored)
  @override
  Future<void> setLooping(int textureId, bool looping) => Future<void>.value();

  /// Sets the audio mode to mix with other sources (ignored)
  @override
  Future<void> setMixWithOthers(bool mixWithOthers) => Future<void>.value();
}
