import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/challenge_helper.dart';

class DailyChallengeScreen extends StatefulWidget {
  final String challenge;

  const DailyChallengeScreen({super.key, required this.challenge});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  bool _completed = false;
  bool _loading = true;
  String? _responseText;
  File? _responseImage;

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final done = await isChallengeCompleted();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final response = await getResponseForDate(today);

    setState(() {
      _completed = done;
      _responseText = response['text'];
      if (response['imagePath'] != null) {
        _responseImage = File(response['imagePath']!);
      }
      _loading = false;
    });
  }

  Future<void> _saveResponse() async {
    final text = _textController.text.trim();
    String? imagePath;

    if (_responseImage != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/response_${DateTime.now().toIso8601String()}.png';
      await _responseImage!.copy(path);
      imagePath = path;
    }

    await saveResponse(text: text, imagePath: imagePath);
    await markChallengeAsCompleted();

    setState(() {
      _completed = true;
      _responseText = text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Respuesta guardada!')),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _responseImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Reto del Día')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Reto del Día')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu reto de hoy:', style: TextStyle(fontSize: 22)),
            SizedBox(height: 16),
            Text(widget.challenge, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            if (_completed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  SizedBox(height: 8),
                  Text('¡Reto completado!', style: TextStyle(color: Colors.green, fontSize: 18)),
                  if (_responseText != null) ...[
                    SizedBox(height: 16),
                    Text('Tu respuesta:', style: TextStyle(fontSize: 18)),
                    Text(_responseText!),
                  ],
                  if (_responseImage != null) ...[
                    SizedBox(height: 16),
                    Image.file(_responseImage!, height: 200),
                  ],
                ],
              )
            else
              Column(
                children: [
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'Escribe tu respuesta',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  if (_responseImage != null)
                    Image.file(_responseImage!, height: 200),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: Text('Añadir imagen'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveResponse,
                    child: Text('Guardar respuesta'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}