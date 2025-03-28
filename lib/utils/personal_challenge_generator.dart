import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, List<String>> challengePool = {
  'Fotografía': [
    'Toma una foto usando solo luz natural.',
    'Haz una foto de algo que tenga textura interesante.',
    'Retrata algo cotidiano como si fuera arte abstracto.',
  ],
  'Escritura': [
    'Escribe una mini historia en 3 frases.',
    'Describe un lugar real como si fuera un sueño.',
    'Crea un diálogo entre dos objetos del escritorio.',
  ],
  'Dibujo': [
    'Dibuja una emoción sin usar caras.',
    'Haz un doodle sin levantar el lápiz.',
    'Ilustra tu desayuno como si fuera un cómic.',
  ],
  // Puedes añadir más...
};

Future<String> getPersonalizedChallenge() async {
  final prefs = await SharedPreferences.getInstance();
  final interests = prefs.getStringList('user_interests') ?? [];

  if (interests.isEmpty) {
    return 'Primero selecciona tus intereses creativos.';
  }

  final random = Random();
  final chosenInterest = interests[random.nextInt(interests.length)];
  final challenges = challengePool[chosenInterest];

  if (challenges == null || challenges.isEmpty) {
    return 'No hay retos disponibles aún para $chosenInterest.';
  }

  final selectedChallenge = challenges[random.nextInt(challenges.length)];
  return '[$chosenInterest] $selectedChallenge';
}