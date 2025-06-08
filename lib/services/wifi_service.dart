import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class WiFiService {
  static Future<Map<String, String?>> getWiFiInfo() async {
    try {
      // Request location permission (required for WiFi info on Android)
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        return {'ssid': 'Permission denied', 'bssid': 'Permission denied'};
      }

      final networkInfo = NetworkInfo();

      final ssid = await networkInfo.getWifiName();
      final bssid = await networkInfo.getWifiBSSID();

      return {
        'ssid': ssid?.replaceAll('"', '') ?? 'Unknown',
        'bssid': bssid ?? 'Unknown',
      };
    } catch (e) {
      print('Error getting WiFi info: $e');
      return {'ssid': 'Error', 'bssid': 'Error'};
    }
  }
}
