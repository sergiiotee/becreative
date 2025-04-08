import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/portfolio_helper.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool _loading = true;
  List<Map<String, String?>> _responses = [];

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    final resps = await getAllChallengeResponses();
    setState(() {
      _responses = resps;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Portafolio Creativo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _responses.isEmpty
              ? const Center(child: Text('Aún no has subido ninguna respuesta.'))
              : ListView.builder(
                  itemCount: _responses.length,
                  itemBuilder: (context, index) {
                    final response = _responses[index];
                    final text = response['text'] ?? '';
                    final imagePath = response['imagePath'];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(text, style: const TextStyle(fontSize: 16)),
                            if (imagePath != null) ...[
                              const SizedBox(height: 8),
                              Image.file(File(imagePath), height: 200, fit: BoxFit.cover),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}