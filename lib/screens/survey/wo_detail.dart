import 'package:flutter/material.dart';
import 'survey_input.dart';
import 'package:sidasi/screens/home_page.dart';
import 'package:sidasi/screens/profile_page.dart';

class WoDetailPage extends StatelessWidget {
  final Map<String, dynamic> survey;

  WoDetailPage({required this.survey});

  void _navigateToSurveyInput(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SurveyInputPage(survey: survey)),
    );
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
                  (route) => false),
              child: Text(
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Survey: ${survey['title']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Requestor: ${survey['questor_name']}"),
            Text("Customer: ${survey['customer_name']}"),
            Text("Address: ${survey['address']}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToSurveyInput(context),
              child: Text("Isi Hasil Survey"),
            ),
          ],
        ),
      ),
    );
  }
}
