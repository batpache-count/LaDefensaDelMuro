// lib/data/bestiary_data.dart
import '../models/bestiary_item.dart';

// Esta es la lista maestra. Si quieres agregar al nuevo héroe después, solo lo añades aquí.
final List<BestiaryItem> bestiaryData = [
  // --- HÉROES ---
  BestiaryItem(
    name: 'The Denfender',
    imagePath: 'assets/images/Defensor-Izq.png', // Ojo: Reemplaza con tus rutas reales
    type: BestiaryType.hero,
    lore: 'El último guardián del muro. Juró proteger el reino de las sombras que acechan en la oscuridad. Su escudo ha resistido mil batallas.',
  ),
  
  // --- MONSTRUOS ---
  BestiaryItem(
    name: 'Goblin',
    imagePath: 'assets/images/goblin.jpg',
    type: BestiaryType.monster,
    lore: 'Pequeñas criaturas codiciosas que atacan en manada. Individualmente son débiles, pero su número es su mayor fuerza.',
  ),
  BestiaryItem(
    name: 'Arpía',
    imagePath: 'assets/images/harpy.jpg',
    type: BestiaryType.monster,
    lore: 'Demonios alados que descienden del cielo para atacar a los desprevenidos. Sus gritos hielan la sangre de los valientes.',
  ),
  BestiaryItem(
    name: 'Morthos (El Golem)',
    imagePath: 'assets/images/morthos.jpg',
    type: BestiaryType.monster,
    lore: 'Un gigante de piedra y magia antigua. Morthos no siente dolor ni piedad. Se dice que fue creado para destruir murallas.',
  ),
];