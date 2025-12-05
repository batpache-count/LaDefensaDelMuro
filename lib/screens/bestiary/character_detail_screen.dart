import 'package:flutter/material.dart';
import '../../models/bestiary_item.dart';

class CharacterDetailScreen extends StatelessWidget {
  final BestiaryItem item;

  const CharacterDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // 1. Lógica para elegir el fondo según el tipo
    final String bgImage = item.type == BestiaryType.hero 
        ? 'assets/images/Castillo1.jpg' 
        : 'assets/images/Castillo.jpg';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFC9A348)), // Flecha dorada
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // --- CAPA 1: EL FONDO ---
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bgImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.8), // Muy oscuro para que resalte el texto
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          
          // --- CAPA 2: EL CONTENIDO ---
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: Column(
                children: [
                  // 2. LA IMAGEN (Con animación Hero)
                  Hero(
                    tag: item.name, // ¡Esto es la magia de la animación!
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Marco circular tipo retrato
                        border: Border.all(color: const Color(0xFFC9A348), width: 4),
                        boxShadow: [
                           BoxShadow(color: const Color(0xFFC9A348).withOpacity(0.3), blurRadius: 20, spreadRadius: 5)
                        ],
                        image: DecorationImage(
                          image: AssetImage(item.imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // 3. LA "LOSA" DE TEXTO (Lore)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6), // Semitransparente
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC9A348).withOpacity(0.5), width: 2),
                    ),
                    child: Column(
                      children: [
                        // TÍTULO
                        Text(
                          item.name.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFC9A348), // Dorado
                            fontFamily: 'PixelFont',
                            fontSize: 26,
                            letterSpacing: 2,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2,2))]
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(color: Colors.grey, thickness: 1),
                        ),

                        // HISTORIA
                        Text(
                          item.lore,
                          style: const TextStyle(
                            color: Color(0xFFE0E0E0), // Blanco hueso
                            fontSize: 18,
                            height: 1.6, // Buen espaciado para leer
                            fontStyle: FontStyle.italic,
                            fontFamily: 'PixelFont', // Opcional: Quítalo si cuesta leer mucho texto pixelado
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}