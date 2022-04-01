import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'constant/strings.dart';
import 'home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TITLE,
      theme: ThemeData(
        brightness: Brightness.light
        
      ),
      darkTheme:ThemeData(
          brightness: Brightness.dark

      ),
      themeMode: ThemeMode.dark,
      home: MyHomePage(),
    );
  }
}
