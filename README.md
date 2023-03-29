## Video Player Media Kit
Video Player Media Kit is a platform interface for video player using media_kit to work on Windows and Linux. This interface allows you to play videos seamlessly in your flutter application.
## How to use
To use Video Player Media Kit in your application, follow the steps below:

1. Add the Video Player Media Kit dependency in your `pubspec.yaml` file:

```
dependencies:
  video_player_media_kit: ^0.0.2
```

2.  Import the package in your Dart code
```
import 'package:video_player_dart_vlc/video_player_media_kit.dart';
```

3.  Initialize the Video Player Media Kit interface in the main function of your app

```
void main() {
  initVideoPlayerMediaKitIfNeeded();
  runApp(MyApp());
}
```


`video_player` is the package used for playing videos on Android, iOS, and web platforms.

`media_kit` is the package used for handling multimedia functionalities on Windows, Linux, and macOS platforms.

