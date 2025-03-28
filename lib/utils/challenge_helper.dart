import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../data/challenges.dart';

Future<String> getDailyChallenge() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now().toIso8601String().substring(0, 10); // yyyy-mm-dd
  final savedDate = prefs.getString('last_challenge_date');
  final savedChallenge = prefs.getString('last_challenge_text');

  if (savedDate == today && savedChallenge != null) {
    return savedChallenge;
  } else {
    final random = Random();
    final challenge = creativeChallenges[random.nextInt(creativeChallenges.length)];
    await prefs.setString('last_challenge_date', today);
    await prefs.setString('last_challenge_text', challenge);
    return challenge;
  }
}

Future<void> markChallengeAsCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final challenge = prefs.getString('last_challenge_text') ?? '';
  
  await prefs.setBool('challenge_completed_$today', true);
  await prefs.setString('challenge_history_$today', challenge);
}

Future<bool> isChallengeCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final completed = prefs.getBool('challenge_completed_$today') ?? false;

  // Si completado, pero no está guardado en historial, lo guardamos ahora
  if (completed && !prefs.containsKey('challenge_history_$today')) {
    final challenge = prefs.getString('last_challenge_text') ?? '';
    if (challenge.isNotEmpty) {
      await prefs.setString('challenge_history_$today', challenge);
    }
  }

  return completed;
}

Future<Map<String, String>> getCompletedChallengesHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  final Map<String, String> history = {};

  for (var key in keys) {
    if (key.startsWith('challenge_history_')) {
      final date = key.replaceFirst('challenge_history_', '');
      final challenge = prefs.getString(key);
      if (challenge != null) {
        history[date] = challenge;
      }
    }
  }

  // Ordenamos por fecha descendente
  final sortedKeys = history.keys.toList()..sort((a, b) => b.compareTo(a));
  final sortedHistory = {for (var k in sortedKeys) k: history[k]!};

  return sortedHistory;
}

Future<void> saveResponse({String? text, String? imagePath}) async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now().toIso8601String().substring(0, 10);

  if (text != null) {
    await prefs.setString('response_text_$today', text);
  }
  if (imagePath != null) {
    await prefs.setString('response_image_$today', imagePath);
  }
}

Future<Map<String, String?>> getResponseForDate(String date) async {
  final prefs = await SharedPreferences.getInstance();
  final text = prefs.getString('response_text_$date');
  final imagePath = prefs.getString('response_image_$date');
  return {
    'text': text,
    'imagePath': imagePath,
  };
}

Future<void> clearAllHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();

  final keysToDelete = keys.where((key) =>
    key.startsWith('challenge_') ||
    key.startsWith('response_text_') ||
    key.startsWith('response_image_') ||
    key == 'last_challenge_date' ||
    key == 'last_challenge_text'
  );

  for (final key in keysToDelete) {
    await prefs.remove(key);
  }
}