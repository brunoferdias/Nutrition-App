import 'package:flutter/material.dart';
import '../../app/constants.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.productName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              result ?? 'Ops, encontrei nada',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
