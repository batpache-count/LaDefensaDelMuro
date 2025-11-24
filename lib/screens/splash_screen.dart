import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:defensa_del_muro/screens/home_screen.dart';
import 'package:defensa_del_muro/screens/auth_screen.dart'; // Import AuthScreen
import 'package:defensa_del_muro/components/loading_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  double _progress = 0.0;

  void _videoListener() {
    if (_controller.value.isInitialized && _controller.value.duration.inMilliseconds > 0) {
      setState(() {
        _progress = _controller.value.position.inMilliseconds / _controller.value.duration.inMilliseconds;
      });
    }

    if (_controller.value.position >= _controller.value.duration) {
      if (mounted) {
        // Check if user is logged in
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (mounted) {
            if (user == null) {
              // No user is signed in, go to AuthScreen
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            } else {
              // User is signed in, go to HomeScreen
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            }
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/fondos/fondo_carga.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
        }
      });

    _controller.addListener(_videoListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (_controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: LoadingBar(progress: _progress),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }
}
