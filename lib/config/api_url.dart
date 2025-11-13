import 'package:google_fonts/google_fonts.dart';
import 'package:sicv_flutter/services/remote_config_service.dart';

class ApiUrl {
  final config = RemoteConfigService();
  late String url = config.apiUrl;
  // late String url = 'http://192.168.1.108:3000/api';
}
