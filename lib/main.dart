import 'package:flutter/material.dart';

import 'constant/strings.dart';
import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TITLE,
      theme: ThemeData(
        primarySwatch: Colors.blue,
          primaryColor: Colors.blueGrey ,
      ),
      home: MyHomePage(title: TITLE),
    );
  }
}
