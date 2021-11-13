import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:googlemap/presentation/home_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Map Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(title: 'Google Map Home Page'),
    );
  }
}
