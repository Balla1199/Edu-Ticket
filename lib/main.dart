import 'package:eduticket/Bottom/Home-With-Bottom-Navigation-Page.dart';
import 'package:eduticket/app-routes.dart';
import 'package:eduticket/screens/login/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eduticket/services/AuthService.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Début de l\'initialisation de Firebase');
  try {
    // Initialisation de Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialisé avec succès');
  } catch (e) {
    print('Erreur lors de l\'initialisation de Firebase: $e');
  }
  
  print('Début de l\'initialisation de l\'administrateur par défaut');
  try {
    await AuthService().initializeDefaultAdmin();
    print('Administrateur par défaut initialisé avec succès');
  } catch (e) {
    print('Erreur lors de l\'initialisation de l\'administrateur par défaut: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edu-Ticket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Route initiale déterminée dynamiquement en fonction de l'état de connexion
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Afficher un écran de chargement en attendant l'état d'authentification
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            // Utilisateur connecté, afficher la HomePage
            return HomeWithBottomNavigationPage();
          } else {
            // Utilisateur non connecté, afficher la LoginPage
            return LoginPage();
          }
        },
      ),
      onGenerateRoute: AppRoutes.generateRoute, // Générateur de route
    );
  }
}
