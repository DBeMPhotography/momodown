import 'package:momodown/core/config/app_config.dart';

/// 后端 API 端点常量。
///
/// [baseUrl] 从 [AppConfig] 读取，支持通过 --dart-define 在编译时覆盖。
/// 路径常量仅包含相对路径，由 DioClient 拼接 baseUrl。
class ApiEndpoints {
  ApiEndpoints._();

  /// 基础 URL（例如 http://localhost:3000/api）
  static String get baseUrl => AppConfig.baseUrl;

  // ─── Auth ───
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';

  // ─── Memo ───
  static const String memos = '/memos';

  // ─── Accounting ───
  static const String transactions = '/transactions';

  // ─── Voice ───
  static const String parseVoice = '/voice/parse';

  // ─── Sync ───
  static const String sync = '/sync';
}
