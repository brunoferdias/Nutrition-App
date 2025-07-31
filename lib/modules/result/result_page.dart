import 'package:flutter/material.dart';
import '../../core/services/openai_service.dart';

class ResultPage extends StatefulWidget {
  final String productName;
  final String apiKey;

  const ResultPage({
    super.key,
    required this.productName,
    required this.apiKey,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String? result;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final service = OpenAIService(widget.apiKey);
      final res = await service.fetchNutritionInfo(widget.productName);
      setState(() {
        result = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        result = 'Erro ao obter dados: ${e.toString()}';
        loading = false;
      });
    }
  }

  String getImageUrl(String productName) {
    final query = Uri.encodeComponent(productName);
    return 'https://source.unsplash.com/400x300/?$query';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.productName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: loading
              ? const CircularProgressIndicator()
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                getImageUrl(widget.productName),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                result ?? 'Nenhuma informação encontrada.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
