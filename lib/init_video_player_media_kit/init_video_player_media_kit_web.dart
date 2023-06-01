import 'package:media_kit/media_kit.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
/// Initializes the VideoPlayerMediaKit plugin if running on a supported platform.
///
/// On Windows, Linux, and macOS, this function registers the VideoPlayerMediaKit
/// plugin using the `registerWith()` method. On iOS, it also registers the plugin
/// if the `iosUseMediaKit` parameter is set to `true`. On Android, it registers
/// the plugin using the `registerWith()` method if the `androidUseMediaKit`
/// parameter is set to `true`.
///
/// If the current platform is not supported or is the web platform, this function
/// does nothing.
///
/// Parameters:
/// - `iosUseMediaKit`: A boolean value indicating whether to register the plugin on iOS.
/// - `androidUseMediaKit`: A boolean value indicating whether to register the plugin on Android.
/// - `logLevel`: A `LogLevel` value indicating the desired log level.
void initVideoPlayerMediaKitIfNeeded(
    {bool iosUseMediaKit = false,
    bool androidUseMediaKit = false,
    MPVLogLevel logLevel = MPVLogLevel.warn}) {}
