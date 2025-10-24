// pubspec.yaml ga qo'shish kerak:
// dependencies:
//   flutter:
//     sdk: flutter
//   get: ^4.6.6
//   supabase_flutter: ^2.0.0
//   intl: ^0.18.1
//   cached_network_image: ^3.3.0

// main.dart
import 'package:admin_job/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lebttvzssavbjkoumebf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlYnR0dnpzc2F2Ymprb3VtZWJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0OTQyNzgsImV4cCI6MjA3NjA3MDI3OH0.psRAzz881AtKLZyjBTZycTJ4fpwte2g3di0loZoQOc8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Job Hunter Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
      ),
      home: const AdminDashboard(),
    );
  }
}

// Models

// Controller

// Main Dashboard
// Applications View
