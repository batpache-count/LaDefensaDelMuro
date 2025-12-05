import 'package:defensa_del_muro/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLogin = true; // To toggle between login and signup
  bool _isLoading = false;

  void _submitAuthForm(String email, String password) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await FirebaseFirestore.instance
            .collection('players')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'createdAt': Timestamp.now(),
        });
      }
      // Navigation is handled by DecisionScreen's stream
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Ocurrió un error, revisa tus credenciales.';
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Ocurrió un error inesperado.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    final user = await FirebaseService().signInWithGoogle();
    if (user == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falló el inicio de sesión con Google'),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/fondos/fondo_home.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.brown[700]!, width: 2),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                          style: const TextStyle(
                            fontFamily: 'Medieval',
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextFormField(
                                key: const ValueKey('email'),
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Correo electrónico',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                ),
                                validator: (value) {
                                  if (value == null || !value.contains('@')) {
                                    return 'Por favor, introduce un correo válido.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _email = value!;
                                },
                              ),
                              TextFormField(
                                key: const ValueKey('password'),
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Contraseña',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.length < 7) {
                                    return 'La contraseña debe tener al menos 7 caracteres.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _password = value!;
                                },
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    _submitAuthForm(_email.trim(), _password.trim());
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700]),
                                child: Text(
                                  _isLogin ? 'Entrar' : 'Crear',
                                  style: const TextStyle(fontFamily: 'Medieval', fontSize: 18, color: Colors.white),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(
                                  _isLogin ? 'Crear una nueva cuenta' : 'Ya tengo una cuenta',
                                  style: const TextStyle(fontFamily: 'Medieval', color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.brown),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 10,
                            child: Text('G', style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold)),
                          ),
                          label: const Text(
                            ' Iniciar sesión con Google',
                            style: TextStyle(fontFamily: 'Medieval', fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
                          onPressed: _signInWithGoogle,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
