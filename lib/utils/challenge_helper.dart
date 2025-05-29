// lib/utils/progressive_challenge_helper.dart

import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/challenges.dart';

/// Obtiene el reto del día. Si ya existe uno guardado para la fecha actual,
/// lo devuelve; de lo contrario, elige uno nuevo aleatorio y lo almacena.
Future<String> getDailyChallenge() async {
  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    print('Error inicializando SharedPreferences: $e');
    return 'Error al cargar reto del día. Intenta más tarde.';
  }

  final today = DateTime.now().toIso8601String().substring(0, 10);
  final savedDate = prefs.getString('last_challenge_date');
  final savedChallenge = prefs.getString('last_challenge_text');

  if (savedDate == today && savedChallenge != null) {
    return savedChallenge;
  }

  final random = Random();
  final challenge = creativeChallenges[random.nextInt(creativeChallenges.length)];
  try {
    await prefs.setString('last_challenge_date', today);
    await prefs.setString('last_challenge_text', challenge);
  } catch (e) {
    print('Error guardando reto del día: $e');
  }
  return challenge;
}

/// Marca el reto del día actual como completado y lo registra en el historial.
Future<void> markChallengeAsCompleted() async {
  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    print('Error inicializando SharedPreferences: $e');
    return;
  }

  final today = DateTime.now().toIso8601String().substring(0, 10);
  final challenge = prefs.getString('last_challenge_text') ?? '';

  try {
    await prefs.setBool('challenge_completed_$today', true);
    await prefs.setString('challenge_history_$today', challenge);
  } catch (e) {
    print('Error marcando reto completado: $e');
  }
}

/// Comprueba si el reto del día actual ya fue completado.
Future<bool> isChallengeCompleted() async {
  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    print('Error inicializando SharedPreferences: $e');
    return false;
  }

  final today = DateTime.now().toIso8601String().substring(0, 10);
  final completed = prefs.getBool('challenge_completed_$today') ?? false;

  // Si marcado como completado pero no hay historial, lo registramos.
  if (completed && !prefs.containsKey('challenge_history_$today')) {
    final challenge = prefs.getString('last_challenge_text') ?? '';
    if (challenge.isNotEmpty) {
      try {
        await prefs.setString('challenge_history_$today', challenge);
      } catch (e) {
        print('Error actualizando historial tras completado: $e');
      }
    }
  }

  return completed;
}

/// Recupera el historial de retos completados: mapa fecha->texto del reto.
Future<Map<String, String>> getCompletedChallengesHistory() async {
  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    print('Error inicializando SharedPreferences: $e');
    return {};
  }

  final keys = prefs.getKeys();
  final history = <String, String>{};

  for (var key in keys) {
    if (key.startsWith('challenge_history_')) {
      final date = key.replaceFirst('challenge_history_', '');
      final challenge = prefs.getString(key);
      if (challenge != null) {
        history[date] = challenge;
      }
    }
  }

  // Ordenar por fecha descendente
  final sortedKeys = history.keys.toList()..sort((a, b) => b.compareTo(a));
  return {for (var k in sortedKeys) k: history[k]!};
}

/// Guarda la respuesta del reto de hoy (texto e imagen).
Future<void> saveResponse({String? text, String? imagePath}) async {
  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    print('Error inicializando SharedPreferences: $e');
    return;
  }

  final today = DateTime.now().toIso8601String().substring(0, 10);
  try {
    if (text != null) await prefs.setString('response_text_$today', text);
    if (imagePath != null) await prefs.setString('response_image_$today', imagePath);
  } catch (e) {
    print('Error guardando respuesta: $e');
  }
}

/// Recupera la respuesta guardada para una fecha dada.
Future<Map<String, String?>> getResponseForDate(String date) async {
  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    print('Error inicializando SharedPreferences: $e');
    return {'text': null, 'imagePath': null};
  }

  final text = prefs.getString('response_text_$date');
  final imagePath = prefs.getString('response_image_$date');
  return {'text': text, 'imagePath': imagePath};
}

/// Borra todo el historial y estado de retos (diario y respuestas).
Future<void> clearAllHistory() async {
  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    print('Error inicializando SharedPreferences: $e');
    return;
  }

  final keys = prefs.getKeys();
  final toDelete = keys.where((k) =>
      k.startsWith('challenge_') ||
      k.startsWith('response_text_') ||
      k.startsWith('response_image_') ||
      k == 'last_challenge_date' ||
      k == 'last_challenge_text');

  for (var key in toDelete) {
    try {
      await prefs.remove(key);
    } catch (e) {
      print('Error borrando clave $key: $e');
    }
  }
}
