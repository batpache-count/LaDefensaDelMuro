import 'package:flutter/material.dart';
import '../../data/bestiary_data.dart';
import '../../models/bestiary_item.dart';
import 'character_detail_screen.dart';

class BestiaryScreen extends StatelessWidget {
  const BestiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<BestiaryItem> heroes = bestiaryData
        .where((item) => item.type == BestiaryType.hero)
        .toList();
    final List<BestiaryItem> monsters = bestiaryData
        .where((item) => item.type == BestiaryType.monster)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true, 
        
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          centerTitle: true,
          title: Image.asset(
            'assets/images/BestiarioButton.gif', 
            height: 60,
            fit: BoxFit.contain,
          ),
          iconTheme: const IconThemeData(color: Color(0xFFC9A348)),
          bottom: TabBar(
            indicatorColor: const Color(0xFFC9A348),
            labelColor: const Color(0xFFC9A348),
            unselectedLabelColor: Colors.grey[600],
            indicatorWeight: 4.0,
            
            // --- ICONOS DEFINITIVOS ---
            tabs: const [
              Tab(icon: Icon(Icons.fort, size: 28), text: "Héroes"),
              Tab(icon: Icon(Icons.whatshot, size: 28), text: "Monstruos"),
            ],
            // --------------------------
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabWithBackground(context, heroes, 'assets/images/Castillo1.jpg'),
            _buildTabWithBackground(context, monsters, 'assets/images/Castillo.jpg'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabWithBackground(BuildContext context, List<BestiaryItem> items, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7), 
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 150), 
        child: _buildGrid(context, items),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<BestiaryItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Aún no se han avistado...', 
          style: TextStyle(color: Colors.white70, fontFamily: 'PixelFont', fontSize: 18)
        )
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // Asegúrate de tener también el código nuevo en character_detail_screen.dart
                // para que la animación tenga a donde llegar.
                builder: (context) => CharacterDetailScreen(item: item),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF303030),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFC9A348),
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 0,
                  offset: const Offset(6, 6),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    child: Container(
                      color: Colors.black54,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        // --- AQUÍ ESTÁ LA ANIMACIÓN HERO ---
                        child: Hero(
                          tag: item.name, // El identificador único para el viaje
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.contain, 
                            errorBuilder: (context, error, stackTrace) => 
                                Icon(Icons.broken_image, size: 50, color: Colors.grey[700]),
                          ),
                        ),
                        // -----------------------------------
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF222222),
                      border: Border(top: BorderSide(color: Color(0xFFC9A348), width: 2))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFE0E0E0),
                          fontFamily: 'PixelFont',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}