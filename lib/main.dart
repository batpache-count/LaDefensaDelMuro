import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:defensa_del_muro/game_state.dart';
import 'package:defensa_del_muro/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Defensa del Muro',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
    );
  }
}
