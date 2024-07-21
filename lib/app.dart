import 'package:flutter/material.dart';
import 'package:googlemap/presentation/home_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Map Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(title: 'Google Map Home Page'),
    );
  }
}
