import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '文件管理器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
            // bodyLarge: TextStyle(fontSize: 16),
            // bodyMedium: TextStyle(fontSize: 14),
            // bodySmall: TextStyle(fontSize: 12),
            // titleLarge: TextStyle(fontSize: 18),
            // titleMedium: TextStyle(fontSize: 16),
            // titleSmall: TextStyle(fontSize: 14),
            // labelLarge: TextStyle(fontSize: 14),
            // labelMedium: TextStyle(fontSize: 12),
            // labelSmall: TextStyle(fontSize: 10),
            ),
      ),
      home: HomePage(),
    );
  }
}
