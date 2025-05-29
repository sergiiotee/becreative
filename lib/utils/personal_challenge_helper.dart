import 'package:shared_preferences/shared_preferences.dart';

Future<void> markPersonalChallengeAsCompleted(String interest, String challenge) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'completed_personal_$interest';
  final existing = prefs.getStringList(key) ?? [];

  if (!existing.contains(challenge)) {
    existing.add(challenge);
    await prefs.setStringList(key, existing);
  }
}

/// Recupera la lista de retos completados para un interés dado.
/// En caso de error, devuelve una lista vacía.
Future<List<String>> getCompletedChallengesForInterest(String interest) async {
  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    print('Error al obtener SharedPreferences: $e');
    return [];
  }

  final key = 'completed_personal_$interest';
  return prefs.getStringList(key) ?? [];
}