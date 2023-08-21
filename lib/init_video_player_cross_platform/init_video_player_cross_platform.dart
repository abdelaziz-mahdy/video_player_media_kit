import 'package:media_kit/media_kit.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:video_player_cross_platform/video_player_cross_platform_platform/video_player_cross_platform_platform.dart';

/// Initializes the VideoPlayerCrossPlatform plugin if running on a supported platform.
///
/// On Windows, Linux, and macOS, this function registers the VideoPlayerCrossPlatform
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
/// - `throwErrors`: when playing errors happens, throw error (can be disabled incase of false positives)
void initVideoPlayerCrossPlatformIfNeeded(
    {bool iosUseMediaKit = false,
    bool androidUseMediaKit = false,
    MPVLogLevel logLevel = MPVLogLevel.warn,
    bool throwErrors = true}) {
  if ((UniversalPlatform.isWindows ||
          UniversalPlatform.isLinux ||
          UniversalPlatform.isMacOS) &&
      !UniversalPlatform.isWeb) {
    MediaKit.ensureInitialized();
    VideoPlayerCrossPlatform.registerWith(
        logLevel: logLevel, throwErrors: throwErrors);
  }
  if (UniversalPlatform.isIOS && iosUseMediaKit) {
    MediaKit.ensureInitialized();
    VideoPlayerCrossPlatform.registerWith(
        logLevel: logLevel, throwErrors: throwErrors);
  }
  if (UniversalPlatform.isAndroid && androidUseMediaKit) {
    MediaKit.ensureInitialized();
    VideoPlayerCrossPlatform.registerWith(
        logLevel: logLevel, throwErrors: throwErrors);
  }
}
