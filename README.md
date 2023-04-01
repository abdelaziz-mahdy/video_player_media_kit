## Video Player Media Kit
Video Player Media Kit is a platform interface for video player using media_kit to work on Windows and Linux and macos. This interface allows you to play videos seamlessly in your flutter application.

Note: this package allows video_player to work across platforms

`video_player` is the package used for playing videos on Android, iOS, and web platforms.

`media_kit` is the package used for handling multimedia functionalities on Windows, Linux, and macOS platforms.

## How to use
To use Video Player Media Kit in your application, follow the steps below:

1. Setup

### Windows

Everything ready.

### Linux

System shared libraries from distribution specific user-installed packages are used by-default. You can install these as follows.

#### Ubuntu / Debian

```bash
sudo apt install libmpv-dev mpv
```

#### Packaging

There are other ways to bundle these within your app package e.g. within Snap or Flatpak. Few examples:

- [Celluloid](https://github.com/celluloid-player/celluloid/blob/master/flatpak/io.github.celluloid_player.Celluloid.json)
- [VidCutter](https://github.com/ozmartian/vidcutter/tree/master/_packaging)
### macOS

Due to media_kit compilation fails these needs to be added (thats a workaround for now until this fix is released)

```yaml
dependency_overrides:
  media_kit:
    git:
      url: https://github.com/zezo357/media_kit
      ref: 6fc3720bea0b162262c9dc48e655b34cfa66903f
      path: ./media_kit
  media_kit_video:
    git:
      url: https://github.com/zezo357/media_kit
      ref: 6fc3720bea0b162262c9dc48e655b34cfa66903f
      path: ./media_kit_video
  media_kit_libs_ios_video:
    git:
      url: https://github.com/zezo357/media_kit
      ref: 6fc3720bea0b162262c9dc48e655b34cfa66903f
      path: ./media_kit_libs_ios_video
  media_kit_native_event_loop:
    git:
      url: https://github.com/zezo357/media_kit
      ref: 6fc3720bea0b162262c9dc48e655b34cfa66903f
      path: ./media_kit_native_event_loop
  media_kit_libs_macos_video:
    git:
      url: https://github.com/zezo357/media_kit
      ref: 6fc3720bea0b162262c9dc48e655b34cfa66903f
      path: ./media_kit_libs_macos_video
```


### iOS (replace original video_player with media_kit one)

1. set IPHONEOS_DEPLOYMENT_TARGET to 13.0 in `ios\Runner.xcodeproj\project.pbxproj`
2. Just add this package in case you set iosUseMediaKit to true in initVideoPlayerMediaKitIfNeeded

```yaml
dependencies:
  ...
  media_kit_libs_ios_video: ^1.0.0         # iOS package for video (& audio) native libraries.
```


1. Add the Video Player Media Kit dependency in your `pubspec.yaml` file:

```
dependencies:
  video_player_media_kit: ^0.0.2
```

3.  Import the package in your Dart code
```
import 'package:video_player_dart_vlc/video_player_media_kit.dart';
```

4.  Initialize the Video Player Media Kit interface in the main function of your app

```
void main() {
  initVideoPlayerMediaKitIfNeeded(); //parameter iosUseMediaKit can be used to make ios use media_kit instead of video_player
  runApp(MyApp());
}
```

now video_player will work on any platform.

