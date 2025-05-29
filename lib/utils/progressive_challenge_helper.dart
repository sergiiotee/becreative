import 'package:shared_preferences/shared_preferences.dart';

final Map<String, List<String>> challengeBank = {
  'Fotografía': [
    'Haz una foto en blanco y negro.',
    'Fotografía algo desde muy cerca.',
    'Captura una sombra interesante.',
    'Haz una foto reflejada en un espejo.',
    'Retrata una emoción solo con objetos.',
    'Haz una serie de fotos sobre lo cotidiano.',
    'Fotografía algo en movimiento.',
    'Toma una foto sin usar la cámara trasera.',
    'Haz una composición minimalista.',
    'Imita la portada de un disco famoso.'
    // Puedes seguir hasta 30 o más...
  ],
  'Escritura': [
    'Escribe un poema de 3 líneas.',
    'Cuenta una historia sin usar la letra A.',
    'Describe tu día como si fuera un sueño.',
    'Escribe un diálogo entre dos objetos.',
    'Crea una historia que ocurra en un ascensor.',
    'Imagina que te despiertas en otro cuerpo.',
    'Escribe un mensaje de despedida sin decir adiós.',
    'Describe una emoción como si fuera un paisaje.',
    'Escribe una carta que nunca enviarías.',
    'Reescribe una escena de película con otro final.'
  ],
  // Añade más intereses y retos
};

/// Marca un reto como completado para un interés dado.
Future<void> markChallengeProgress(String interest, String challenge) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final key = 'progress_$interest';
    final existing = prefs.getStringList(key) ?? [];
    if (!existing.contains(challenge)) {
      existing.add(challenge);
      await prefs.setStringList(key, existing);
    }
  } catch (e) {
    print('Error en markChallengeProgress: $e');
  }
}

/// Obtiene la lista de retos completados para un interés.
Future<List<String>> getCompletedChallengesForInterest(String interest) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final key = 'progress_$interest';
    return prefs.getStringList(key) ?? [];
  } catch (e) {
    print('Error en getCompletedChallengesForInterest: $e');
    return [];
  }
}

Future<void> saveChallengeResponse(String interest, String challenge,
    {String? text, String? imagePath}) async {
  final prefs = await SharedPreferences.getInstance();
  final keyPrefix = '${interest}_${challenge.hashCode}';
  if (text != null) await prefs.setString('response_text_$keyPrefix', text);
  if (imagePath != null) await prefs.setString('response_image_$keyPrefix', imagePath);
}

Future<Map<String, String?>> getChallengeResponse(String interest, String challenge) async {
  final prefs = await SharedPreferences.getInstance();
  final keyPrefix = '${interest}_${challenge.hashCode}';
  final text = prefs.getString('response_text_$keyPrefix');
  final imagePath = prefs.getString('response_image_$keyPrefix');
  return {'text': text, 'imagePath': imagePath};
}

/// Devuelve true si el reto dado ya ha sido marcado como completado
Future<bool> isChallengeCompleted(String interest, String challenge) async {
  try {
    final completedList = await getCompletedChallengesForInterest(interest);
    return completedList.contains(challenge);
  } catch (e) {
    print('Error en isChallengeCompleted: $e');
    return false;
  }
}
