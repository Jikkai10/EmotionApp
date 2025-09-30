import 'package:flutter/material.dart';

import 'face_detector/face_detector.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google ML Kit Demo App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomCard("Face Detection", FaceDetectorView()),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;

  const CustomCard(this._label, this._viewPage, {super.key, this.featureCompleted = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: 300,
        height: 50,
        
        child: ListTile(
          tileColor: Theme.of(context).primaryColor,
          title: Text(
            _label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          onTap: () {
            if (!featureCompleted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      const Text('This feature has not been implemented yet')));
            } else {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => _viewPage));
            }
          },
        ),
      ),
    );
  }
}