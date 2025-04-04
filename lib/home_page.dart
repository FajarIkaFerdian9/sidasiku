import 'package:flutter/material.dart';
import 'package:sidasi/screens/pdf_list.dart';
import 'profile_page.dart';
import 'package:sidasi/screens/survey/survey.dart';
import 'package:sidasi/smart/chatbot.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  TextEditingController _searchController = TextEditingController();

  // Fungsi untuk menangani pencarian
  void _searchFile() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfListPage(searchQuery: query),
        ),
      );
    }
  }

  // Fungsi untuk menangani navigasi bottom navigation bar
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Mencegah reload halaman yang sama

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SurveyPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatbotPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => HomePage())),
              child: Text('SIDASI',
                  style: TextStyle(
                      fontFamily: 'Nico Moji',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange)),
            ),
            IconButton(
              icon: Icon(Icons.account_circle, size: 30, color: Colors.black),
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
      body: Column(
        children: [
          // Search Bar di Bagian Atas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Masukkan Nama File",
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _searchFile,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (value) => _searchFile(),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Cari Drawing Map",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Drawing Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll),
            label: "Survey",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "I-Smart",
          ),
        ],
      ),
    );
  }
}
