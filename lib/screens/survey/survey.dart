import 'package:flutter/material.dart';
import 'package:sidasi/screens/survey/wo_detail.dart';
import 'package:sidasi/screens/survey/survey_input.dart';
import 'package:sidasi/screens/home_page.dart';
import 'package:sidasi/screens/profile_page.dart';
import 'package:sidasi/smart/chatbot.dart';
import 'package:sidasi/services/survey_service.dart';

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final SurveyService _surveyService = SurveyService();
  List<dynamic> _surveys = [];
  int _selectedIndex = 1; // Survey Page Index

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    try {
      final surveys = await _surveyService.fetchSurveys();
      setState(() {
        _surveys = surveys;
      });
    } catch (e) {
      print("Error fetching surveys: $e");
    }
  }

  void _navigateToDetail(Map<String, dynamic> survey) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WoDetailPage(survey: survey)),
    );
  }

  void _navigateToInput(Map<String, dynamic> survey) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SurveyInputPage(survey: survey)),
    ).then((_) => _loadSurveys());
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

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

  Color _getStatusColor(String status) {
    switch (status) {
      case "STANDART":
        return Colors.green;
      case "REJECT":
        return Colors.red;
      case "INCOMPLETE":
        return Colors.yellow;
      default:
        return Colors.orange;
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
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _surveys.length,
        itemBuilder: (context, index) {
          final survey = _surveys[index];
          return Card(
            color: _getStatusColor(survey["status"]),
            child: ListTile(
              title: Text(survey["title"]),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _navigateToInput(survey),
              ),
              onTap: () => _navigateToDetail(survey),
            ),
          );
        },
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
