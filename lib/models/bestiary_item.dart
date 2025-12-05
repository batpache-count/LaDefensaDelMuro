// lib/models/bestiary_item.dart

// Esto nos servirá para separar las pestañas automáticamente
enum BestiaryType { hero, monster }

class BestiaryItem {
  final String name;       // Nombre (Ej: Morthos)
  final String imagePath;  // Ruta de la imagen (Ej: assets/images/golem.png)
  final String lore;       // La historia o descripción
  final BestiaryType type; // Si es Héroe o Monstruo

  BestiaryItem({
    required this.name,
    required this.imagePath,
    required this.lore,
    required this.type,
  });
}