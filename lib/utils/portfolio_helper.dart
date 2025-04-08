import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, String?>>> getAllChallengeResponses() async {
  final prefs = await SharedPreferences.getInstance();
  final responses = <Map<String, String?>>[];

  // Itera todas las claves y filtra las que empiezan por "response_text_"
  for (String key in prefs.getKeys()) {
    if (key.startsWith('response_text_')) {
      final text = prefs.getString(key);
      // La clave de la imagen se obtiene reemplazando el prefijo
      final imageKey = key.replaceFirst('response_text_', 'response_image_');
      final imagePath = prefs.getString(imageKey);
      responses.add({
        'key': key,
        'text': text,
        'imagePath': imagePath,
      });
    }
  }
  return responses;
}