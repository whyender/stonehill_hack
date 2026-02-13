import 'package:flutter/material.dart';

// Comment out Firebase for now
// import 'package:firebase_core/firebase_core.dart';
import 'screens/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Comment out Firebase initialization
  // await Firebase.initializeApp();
  
  runApp(const PetMatchApp());
}

class PetMatchApp extends StatelessWidget {
  const PetMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetMatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF4CAF50),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RoleSelectionScreen(), // Start here instead of SplashScreen
    );
  }
}