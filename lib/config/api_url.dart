import 'package:sicv_flutter/services/remote_config_service.dart';

class ApiUrl {
  final config = RemoteConfigService();
  // late String url = config.apiUrl;
  late String url = 'http://localhost:3000/api';
}
