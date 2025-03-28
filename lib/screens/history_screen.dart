import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/challenge_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, String> _history = {};
  Map<String, Map<String, String?>> _responses = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await getCompletedChallengesHistory();
    final Map<String, Map<String, String?>> responses = {};

    for (final date in data.keys) {
      final response = await getResponseForDate(date);
      responses[date] = response;
    }

    setState(() {
      _history = data;
      _responses = responses;
      _loading = false;
    });
  }

  Future<void> _confirmAndClearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Estás seguro?'),
        content: Text('Esto borrará todo tu historial de retos y respuestas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sí, borrar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await clearAllHistory();

      if (context.mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Historial eliminado. ¡Listo para empezar de nuevo!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Retos'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Borrar historial',
            onPressed: _confirmAndClearHistory,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(child: Text('Aún no has completado ningún reto.'))
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final date = _history.keys.elementAt(index);
                    final challenge = _history[date]!;
                    final response = _responses[date];
                    final responseText = response?['text'];
                    final responseImagePath = response?['imagePath'];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📅 $date', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 6),
                              Text(challenge),
                              if (responseText != null && responseText.isNotEmpty) ...[
                                SizedBox(height: 12),
                                Text('✏️ Tu respuesta:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(responseText),
                              ],
                              if (responseImagePath != null) ...[
                                SizedBox(height: 12),
                                Text('📷 Imagen:', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 6),
                                Image.file(File(responseImagePath), height: 150, fit: BoxFit.cover),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}