import 'package:defensa_del_muro/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:defensa_del_muro/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:defensa_del_muro/game_state.dart';

class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Update GameState with the latest user status
        Provider.of<GameState>(context, listen: false).setUser(snapshot.data);
        print('DecisionScreen: setUser called with ${snapshot.data?.email}');

        // Decide which screen to show
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
