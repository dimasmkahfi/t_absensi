import 'package:screen_brightness/screen_brightness.dart';

class DeviceControlHelper {
  double? _originalBrightness;

  Future<void> setBrightness(double brightness) async {
    try {
      _originalBrightness = await ScreenBrightness().current;
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      print('Error setting brightness: $e');
    }
  }

  Future<void> resetBrightness() async {
    try {
      if (_originalBrightness != null) {
        await ScreenBrightness().setScreenBrightness(_originalBrightness!);
      } else {
        await ScreenBrightness().resetScreenBrightness();
      }
    } catch (e) {
      print('Error resetting brightness: $e');
    }
  }
}
