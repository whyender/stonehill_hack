import 'package:flutter/material.dart';

import 'screens/role_selection_screen.dart';

//wait for firebase init to run code or it will explode
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const PetMatchApp());
}

class PetMatchApp extends StatelessWidget {
  const PetMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PETFINDRRRR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF4CAF50),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RoleSelectionScreen(), 
    );
  }
}