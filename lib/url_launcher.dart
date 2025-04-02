import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(LauncherPage());
}

class LauncherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Test URL Launcher')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              const url = 'https://www.google.com';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                print("Tidak bisa membuka URL");
              }
            },
            child: Text("Buka Google"),
          ),
        ),
      ),
    );
  }
}
