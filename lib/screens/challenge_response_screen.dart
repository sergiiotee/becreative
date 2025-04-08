import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/progressive_challenge_helper.dart';

class ChallengeResponseScreen extends StatefulWidget {
  final String interest;
  final String challenge;

  const ChallengeResponseScreen({
    super.key,
    required this.interest,
    required this.challenge,
  });

  @override
  State<ChallengeResponseScreen> createState() => _ChallengeResponseScreenState();
}

class _ChallengeResponseScreenState extends State<ChallengeResponseScreen> {
  final _controller = TextEditingController();
  File? _image;
  bool _alreadyCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadResponse();
  }

  Future<void> _loadResponse() async {
    // Cargamos la respuesta (texto e imagen) si ya se guardó anteriormente.
    final response = await getChallengeResponse(widget.interest, widget.challenge);
    if (response['text'] != null) {
      _controller.text = response['text']!;
    }
    if (response['imagePath'] != null) {
      final path = response['imagePath']!;
      if (File(path).existsSync()) {
        setState(() {
          _image = File(path);
        });
      }
    }
    // Consultamos si este reto ya está marcado como completado.
    final completed = await isChallengeCompleted(widget.interest, widget.challenge);
    setState(() {
      _alreadyCompleted = completed;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _save() async {
    String? imagePath;
    if (_image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final filename = '${widget.interest}_${widget.challenge.hashCode}.jpg';
      final savedImage = await _image!.copy('${directory.path}/$filename');
      imagePath = savedImage.path;
    }

    // Guarda la respuesta (texto e imagen) para este reto e interés.
    await saveChallengeResponse(
      widget.interest,
      widget.challenge,
      text: _controller.text.trim(),
      imagePath: imagePath,
    );

    // Marca como completado el reto para el interés.
    await markChallengeProgress(widget.interest, widget.challenge);

    setState(() {
      _alreadyCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Reto guardado y marcado como completado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reto')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.challenge,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Tu respuesta (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              if (_image != null)
                Image.file(_image!, height: 200, fit: BoxFit.cover),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Subir imagen'),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(Icons.check),
                label: Text(_alreadyCompleted ? 'Actualizar' : 'Guardar y marcar como hecho'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}