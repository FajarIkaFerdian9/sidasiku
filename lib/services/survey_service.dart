import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyService {
  final Dio _dio = Dio();
  final String baseUrl = "http://192.168.1.8:3000/api/v1";

  Future<List<dynamic>> fetchSurveys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    String? sessionToken = prefs.getString('session_token');

    if (userId == null || sessionToken == null) {
      throw Exception(
          "❌ User ID atau Session Token tidak ditemukan. Harap login ulang.");
    }

    try {
      Response response = await _dio.get(
        '$baseUrl/surveys',
        queryParameters: {
          "surveyor_id": userId
        }, // Gunakan ID user untuk filter survey
        options: Options(
          headers: {
            "Authorization":
                "Bearer $sessionToken", // Tambahkan otorisasi token
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ Berhasil mendapatkan data survey");
        return response.data['data']; // Ambil daftar survey dari API
      } else {
        print("⚠️ Gagal mendapatkan survey: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error saat mengambil survey: $e");
      return [];
    }
  }

  Future<int> submitSurvey(
      String surveyId, String description, String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');

    if (sessionToken == null) {
      print("❌ Tidak ada session token, harap login ulang.");
      return 401;
    }

    try {
      FormData formData = FormData.fromMap({
        "description": description,
        "image": await MultipartFile.fromFile(imagePath,
            filename: imagePath.split('/').last),
      });

      Response response = await _dio.post(
        '$baseUrl/surveys/$surveyId',
        data: formData,
        options: Options(headers: {
          "Authorization": "Bearer $sessionToken",
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Survey berhasil dikirim!");
        return 200;
      } else {
        print("⚠️ Gagal mengirim survey: ${response.statusCode}");
        return response.statusCode ?? 500;
      }
    } catch (e) {
      print("❌ Error saat mengirim survey: $e");
      return 500;
    }
  }
}
