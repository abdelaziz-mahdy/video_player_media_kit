//this file to allow builds for web

import 'package:flutter/material.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class VideoPlayerMediaKit implements VideoPlayerPlatform {
  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {}
  @override
  Widget buildView(int textureId) {
    // TODO: implement buildView
    throw UnimplementedError();
  }

  @override
  Future<int?> create(DataSource dataSource) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> dispose(int textureId) {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<Duration> getPosition(int textureId) {
    // TODO: implement getPosition
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<void> pause(int textureId) {
    // TODO: implement pause
    throw UnimplementedError();
  }

  @override
  Future<void> play(int textureId) {
    // TODO: implement play
    throw UnimplementedError();
  }

  @override
  Future<void> seekTo(int textureId, Duration position) {
    // TODO: implement seekTo
    throw UnimplementedError();
  }

  @override
  Future<void> setLooping(int textureId, bool looping) {
    // TODO: implement setLooping
    throw UnimplementedError();
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) {
    // TODO: implement setMixWithOthers
    throw UnimplementedError();
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) {
    // TODO: implement setPlaybackSpeed
    throw UnimplementedError();
  }

  @override
  Future<void> setVolume(int textureId, double volume) {
    // TODO: implement setVolume
    throw UnimplementedError();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    // TODO: implement videoEventsFor
    throw UnimplementedError();
  }
  
  @override
  Future<void> setWebOptions(int textureId, VideoPlayerWebOptions options) {
    // TODO: implement setWebOptions
    throw UnimplementedError();
  }
}
