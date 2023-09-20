import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neu_llm_studio/screens/home/home.dart';
import 'package:neu_llm_studio/themes/color_scheme.dart';
import 'package:neu_llm_studio/themes/custom_theme.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: CustomTheme().buildLightTheme(),
      darkTheme: CustomTheme().buildDarkTheme().copyWith(navigationRailTheme: NavigationRailThemeData(
        elevation: 10,
        groupAlignment: 0.0
      )),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

