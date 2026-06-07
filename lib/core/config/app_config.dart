/// 应用全局配置，支持编译时通过 --dart-define 覆盖。
///
/// 用法示例：
/// ```bash
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000/api
/// ```
class AppConfig {
  AppConfig._();

  static const String _defaultBaseUrl = 'http://localhost:3000/api';

  /// API 基础地址
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    return envUrl.isEmpty ? _defaultBaseUrl : envUrl;
  }

  /// 是否为调试模式
  static bool get isDebug {
    const envDebug = String.fromEnvironment('DEBUG');
    if (envDebug.isEmpty) return true;
    return envDebug.toLowerCase() == 'true';
  }
}
