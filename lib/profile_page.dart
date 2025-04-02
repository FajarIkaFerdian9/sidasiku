import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Dio dio = Dio();
  String? userName, email, password, callSign, contractor;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');
    String? userId = prefs.getString('user_id');

    if (sessionToken == null || userId == null) {
      print("Session token atau User ID tidak ditemukan, kembali ke login.");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
      return;
    }

    try {
      Response response = await dio.get(
        'http://localhost:3000/api/v1/users',
        queryParameters: {"user_id": userId},
        options: Options(headers: {"Authorization": "Bearer $sessionToken"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userName = response.data['data']['name'];
          email = response.data['data']['email'];
          password = response.data['data']['password'];
          callSign = response.data['data']['call_sign'];
          contractor = response.data['data']['contractor'];
        });
      } else {
        print("Gagal mengambil data user: ${response.data}");
      }
    } catch (e) {
      print("Error mengambil data user: $e");
    }
  }

  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      await dio.post(
        'http://localhost:3000/api/v1/logout',
        options: Options(headers: {
          "Authorization": "Bearer ${prefs.getString('session_token')}"
        }),
      );
    } catch (e) {
      print("Logout gagal: $e");
    }

    // Hapus session dari SharedPreferences
    await prefs.clear();

    // Arahkan ke halaman login
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: userName == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header SIDASI (klik untuk kembali ke home_page.dart)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    child: Text(
                      "SIDASI",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  Text(
                    "User Profile",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.black),
                  ),
                  SizedBox(height: 20),

                  buildProfileField(userName ?? "Loading..."),
                  buildProfileField(callSign ?? "Loading..."),
                  buildProfileField(email ?? "Loading..."),

                  TextField(
                    readOnly: true,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    controller:
                        TextEditingController(text: password ?? "********"),
                  ),
                  SizedBox(height: 10),

                  buildProfileField(contractor ?? "Loading..."),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: logoutUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: Text(
                      "Logout",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildProfileField(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        controller: TextEditingController(text: value),
      ),
    );
  }
}
