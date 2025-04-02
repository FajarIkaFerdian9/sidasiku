import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'pdf_viewer.dart';

class PdfListPage extends StatefulWidget {
  final String searchQuery;
  PdfListPage({required this.searchQuery});

  @override
  _PdfListPageState createState() => _PdfListPageState();
}

class _PdfListPageState extends State<PdfListPage> {
  List<Map<String, dynamic>> _fileList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    try {
      Response response =
          await Dio().get('http://192.168.1.8:3000/api/v1/files');

      if (response.statusCode == 200) {
        List<dynamic> files = response.data['data'];
        setState(() {
          _fileList = files
              .where((file) => file['file_name']
                  .toLowerCase()
                  .contains(widget.searchQuery.toLowerCase()))
              .map((file) => {
                    'id': file['id'],
                    'file_name': file['file_name'],
                  })
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching files: $e");
      setState(() => _isLoading = false);
    }
  }

  void _requestAccess(String fileId, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Izin Akses"),
        content: Text("Apakah Anda ingin membuka file ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndOpenFile(fileId, fileName);
            },
            child: Text("Buka"),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndOpenFile(String fileId, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';

      // ✅ Download file dari API
      Response response = await Dio().download(
        'http://192.168.1.8:3000/api/v1/files/download?id=$fileId',
        filePath,
      );

      if (response.statusCode == 200) {
        if (fileName.endsWith('.pdf')) {
          // ✅ Jika file PDF, buka di pdf_viewer.dart
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewer(filePath: filePath),
            ),
          );
        } else if (fileName.endsWith('.kmz')) {
          // ✅ Jika file KMZ, buka di Google Earth
          _openKmzFile(filePath);
        } else {
          // ✅ Jika format lain, coba buka dengan aplikasi default
          OpenFile.open(filePath);
        }
      } else {
        print("Gagal mengunduh file");
      }
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  void _openKmzFile(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        // ✅ Buka file KMZ dengan aplikasi yang mendukung (Google Earth)
        OpenFile.open(filePath);
      } else {
        print("File tidak ditemukan.");
      }
    } catch (e) {
      print("Gagal membuka Google Earth: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hasil Pencarian")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _fileList.isEmpty
              ? Center(child: Text("Tidak ada file ditemukan."))
              : ListView.builder(
                  itemCount: _fileList.length,
                  itemBuilder: (context, index) {
                    final file = _fileList[index];
                    return ListTile(
                      title: Text(file['file_name']),
                      onTap: () =>
                          _requestAccess(file['id'], file['file_name']),
                    );
                  },
                ),
    );
  }
}
