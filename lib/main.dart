// main.dart - Namoz Vaqtlari ilova (Modular Architecture)
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

// Main App
void main() {
  runApp(NamozVaqtlariApp());
}

class NamozVaqtlariApp extends StatelessWidget {
  const NamozVaqtlariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namoz Vaqtlari - Uzbekistan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: false),
      home: MainScreen(),
    );
  }
}
