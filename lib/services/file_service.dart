import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:sidasi/screens/pdf_viewer.dart';

class FileService {
  static final String baseUrl = 'http://192.168.1.8:3000/api/v1';

  // ✅ Fetch daftar file berdasarkan query
  static Future<List<Map<String, dynamic>>> fetchFiles(
      String searchQuery) async {
    try {
      Response response = await Dio().get('$baseUrl/files');

      if (response.statusCode == 200) {
        List<dynamic> files = response.data['data'];
        return files
            .where((file) => file['file_name']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .map((file) => {
                  'id': file['id'],
                  'file_name': file['file_name'],
                })
            .toList();
      }
    } catch (e) {
      print("Error fetching files: $e");
    }
    return [];
  }

  // ✅ Download & buka file
  static Future<void> downloadAndOpenFile(
      BuildContext context, String fileId, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';

      Response response = await Dio().download(
        '$baseUrl/files/download?id=$fileId',
        filePath,
      );

      if (response.statusCode == 200) {
        if (fileName.endsWith('.pdf')) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PdfViewer(filePath: filePath)),
          );
        } else if (fileName.endsWith('.kmz')) {
          _openKmzFile(filePath);
        } else {
          OpenFile.open(filePath);
        }
      } else {
        print("Gagal mengunduh file");
      }
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  // ✅ Buka file KMZ
  static void _openKmzFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        OpenFile.open(filePath);
      } else {
        print("File tidak ditemukan.");
      }
    } catch (e) {
      print("Gagal membuka Google Earth: $e");
    }
  }
}
