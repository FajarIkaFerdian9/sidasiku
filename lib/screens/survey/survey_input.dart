import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sidasi/screens/home_page.dart';
import 'package:sidasi/screens/profile_page.dart';
import 'package:sidasi/services/survey_service.dart';

class SurveyInputPage extends StatefulWidget {
  final Map<String, dynamic> survey;

  const SurveyInputPage({Key? key, required this.survey}) : super(key: key);

  @override
  _SurveyInputPageState createState() => _SurveyInputPageState();
}

class _SurveyInputPageState extends State<SurveyInputPage> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  /// **🔹 Fungsi untuk memilih gambar dari galeri**
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("⚠️ Error picking image: $e");
    }
  }

  /// **🔹 Fungsi untuk mengambil gambar dengan kamera**
  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("⚠️ Error taking photo: $e");
    }
  }

  /// **🔹 Fungsi untuk mengirim survey ke server**
  Future<void> _submitSurvey() async {
    if (_descriptionController.text.isEmpty || _selectedImage == null) {
      _showSnackbar("Deskripsi dan gambar harus diisi!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SurveyService().submitSurvey(
        widget.survey['id'],
        _descriptionController.text,
        _selectedImage!.path,
      );

      _showSnackbar("Survey berhasil disimpan!", success: true);
      Navigator.pop(context);
    } catch (e) {
      print("❌ Error submitting survey: $e");
      _showSnackbar("Gagal menyimpan survey!");
    }

    setState(() => _isLoading = false);
  }

  /// **🔹 Fungsi untuk menampilkan Snackbar (pesan notifikasi)**
  void _showSnackbar(String message, {bool success = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false,
              ),
              child: const Text(
                'SIDASI',
                style: TextStyle(
                  fontFamily: 'Nico Moji',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle,
                  size: 30, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Survey: ${widget.survey['title'] ?? 'Tidak Diketahui'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Masukkan hasil survey...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: Text("Belum ada gambar")),
                  ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar"),
                  onPressed: _pickImage,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text("Ambil Foto"),
                  onPressed: _takePhoto,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitSurvey,
                    child: const Text("Simpan Survey"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.orange,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
