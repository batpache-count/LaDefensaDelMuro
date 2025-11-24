import 'package:defensa_del_muro/game_state.dart';
import 'package:defensa_del_muro/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:defensa_del_muro/screens/level_select_screen.dart';
import 'package:defensa_del_muro/screens/settings_screen.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  final FirebaseService _firebaseService = FirebaseService();

  static const List<String> _loadingMessages = [
    "Huyendo de los goblins… por ahora.",
    "Cargando castillos… ¡que no se derrumben!",
    "Los goblins están tramando algo…",
    "Las criaturas están despertando…",
    "Ajustando armaduras… que no se oxiden.",
    "Reparando las murallas del castillo…",
    "Persiguiendo goblins traviesos…",
    "Los monstruos están afilando sus garras…",
    "Recolectando monedas doradas…",
    "Encendiendo antorchas…",
    "Buscando el castillo más alto…",
    "Los goblins y las demás criaturas están muy callados… sospechoso.",
    "Preparando trampas para los invasores…",
    "Los calderos están hirviendo.",
    "Cargando cofres llenos de secretos…",
    "Acomodando espadas y escudos…",
    "Patrullando los alrededores del castillo…",
    "Los arqueros están apuntando… espero que no a ti.",
    "Revisando pociones… algunas siguen burbujeando.",
    "Buscando runas antiguas…",
  ];

  String _currentLoadingMessage = '';
  Timer? _timer;
  final Random _random = Random();
  double _backgroundOffsetY = 0.0;

  @override
  void initState() {
    super.initState();

    // Inicializar video
    _videoPlayerController = VideoPlayerController.asset(
      'assets/fondos/fondo_home.mp4',
    );
    _initializeVideoPlayerFuture = _videoPlayerController.initialize().then((
      _,
    ) {
      _videoPlayerController.setLooping(true);
      _videoPlayerController.setVolume(0.0);
      _videoPlayerController.play();
      setState(() {}); // fuerza rebuild
    });

    // Mensaje inicial
    _updateLoadingMessage();

    // Cambiar mensaje cada minuto
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _updateLoadingMessage();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _updateLoadingMessage() {
    setState(() {
      _currentLoadingMessage =
          _loadingMessages[_random.nextInt(_loadingMessages.length)];
    });

    print("Mensaje cambiado a: $_currentLoadingMessage");
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final gameState = Provider.of<GameState>(context, listen: false);
    final user = await _firebaseService.signInWithGoogle(context);
    if (user != null) {
      gameState.setUser(user);
      final playerData = await _firebaseService.getPlayerData(user.uid);
      if (playerData != null && playerData.exists) {
        gameState.fromJson(playerData.data() as Map<String, dynamic>);
      } else {
        // If no data, save initial state
        await _firebaseService.savePlayerData(user.uid, gameState.toJson());
      }
      Navigator.pop(context); // Close drawer
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final gameState = Provider.of<GameState>(context, listen: false);
    await _firebaseService.signOut();
    gameState.reset();
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          // Video de fondo
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(15, _backgroundOffsetY),
                    child: SizedBox.expand(
                      child: Center(
                        child: SizedBox(
                          width:
                              MediaQuery.of(context).size.width *
                              1.6, // ← lo hacemos más ancho
                          height: MediaQuery.of(context).size.height,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoPlayerController.value.size.width,
                              height: _videoPlayerController.value.size.height,
                              child: VideoPlayer(_videoPlayerController),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Container(color: Colors.black);
              }
            },
          ),

          // Contenido del Home
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      '', // Aquí puedes poner el título del juego si quieres
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Medieval',
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withAlpha((255 * 0.8).round()),
                            offset: const Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Botones del menú
                _MenuButton(
                  imagePath: 'assets/botones/PlayButton.gif',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LevelSelectScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  imagePath: 'assets/botones/TiendaButton.gif',
                  onPressed: () {},
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  imagePath: 'assets/botones/BestiarioButton.gif',
                  onPressed: () {},
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  imagePath: 'assets/botones/ScoreboardButton.gif',
                  onPressed: () {},
                ),
                const SizedBox(height: 40),

                // Mensaje aleatorio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      _currentLoadingMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontFamily: 'Medieval',
                        shadows: [
                          Shadow(
                            blurRadius: 8.0,
                            color: Colors.black.withAlpha((255 * 0.9).round()),
                            offset: const Offset(3.0, 3.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Hamburger Menu
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: IconButton(
              icon: Image.asset(
                'assets/botones/New Piskel.png',
                width: 40,
                height: 40,
              ),
              onPressed: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ),
        ],
      ),
      // Drawer de ajustes
      endDrawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondos/fondo_ajustes.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Consumer<GameState>(
            builder: (context, gameState, child) {
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade900
                          .withAlpha((255 * 0.7).round()),
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Menú',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Medieval',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (gameState.isLoggedIn) ...[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            gameState.userPhotoUrl ?? ''),
                        radius: 20,
                      ),
                      title: Text(
                        gameState.userEmail ?? 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Medieval',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Medieval',
                          fontSize: 20,
                        ),
                      ),
                      onTap: () => _signOut(context),
                    ),
                  ] else ...[
                    ListTile(
                      leading: const Icon(Icons.login, color: Colors.white),
                      title: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Medieval',
                          fontSize: 20,
                        ),
                      ),
                      onTap: () => _signInWithGoogle(context),
                    ),
                  ],
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text(
                      'Ajustes',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Medieval',
                        fontSize: 20,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const _MenuButton({required this.imagePath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(imagePath, height: 70, fit: BoxFit.contain),
    );
  }
}
