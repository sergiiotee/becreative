import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final List<String> _allInterests = [
    'Fotografía',
    'Escritura',
    'Dibujo',
    'Improvisación',
    'Diseño',
    'Cocina creativa',
    'Storytelling',
    'Arte digital',
    'Manualidades',
    'Otros'
  ];

  final Set<String> _selectedInterests = {};

  Future<void> _saveInterests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_interests', _selectedInterests.toList());

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Intereses guardados!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tus intereses creativos')),
      body: ListView(
        children: _allInterests.map((interest) {
          final selected = _selectedInterests.contains(interest);
          return CheckboxListTile(
            title: Text(interest),
            value: selected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedInterests.add(interest);
                } else {
                  _selectedInterests.remove(interest);
                }
              });
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveInterests,
        label: Text('Guardar'),
        icon: Icon(Icons.check),
      ),
    );
  }
}