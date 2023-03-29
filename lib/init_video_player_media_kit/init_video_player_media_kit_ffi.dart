import 'package:universal_platform/universal_platform.dart';
import 'package:video_player_media_kit/video_player_media_kit_platform/video_player_media_kit_platform_ffi.dart';


void initVideoPlayerMediaKirIfNeeded({bool iosUseMediaKit=false}) {
  if((UniversalPlatform.isWindows||UniversalPlatform.isLinux||UniversalPlatform.isMacOS)&&!UniversalPlatform.isWeb){
    VideoPlayerMediaKit.registerWith();
  }
  if(UniversalPlatform.isIOS&&iosUseMediaKit){
    VideoPlayerMediaKit.registerWith();
  }
}
