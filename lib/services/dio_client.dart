import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.8:3000/api/v1',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {
      "Accept": "application/json",
    },
  ));

  static Dio getInstance() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? sessionToken = prefs.getString('session_token');
        String? csrfToken = prefs.getString('csrf_token');

        if (sessionToken != null) {
          options.headers.addAll({
            "Authorization":
                "Bearer $sessionToken", // ✅ Pastikan format "Bearer <token>"
            "X-CSRF-Token": csrfToken ?? "",
          });
        }

        print("🔍 [REQUEST] ${options.method} ${options.uri}");
        print("📝 Headers: ${options.headers}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("✅ [RESPONSE] ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("❌ [ERROR] ${e.response?.statusCode}");
        return handler.next(e);
      },
    ));
    return _dio;
  }
}
