import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/models/message_history.dart';

final productNameProvider = StateProvider<String>((ref) => '');

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final TextEditingController _controller;
  late final Box<MessageHistory> _historyBox;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _historyBox = Hive.box<MessageHistory>('historyBox');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateText(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    ref.read(productNameProvider.notifier).state = text;
  }

  Future<void> _onSearch() async {
    final productName = ref.read(productNameProvider);
    if (productName.trim().isEmpty) return;

    // Salva no histórico só a pergunta (nome do produto)
    final historyItem = MessageHistory(
      question: productName.trim(),
      answer: '',
      date: DateTime.now(),
    );

    await _historyBox.add(historyItem);

    if (!mounted) return;
    Navigator.pushNamed(context, '/result', arguments: productName);
  }

  @override
  Widget build(BuildContext context) {
    final productName = ref.watch(productNameProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('NutriScan AI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Nome do produto'),
              onChanged: (value) =>
              ref.read(productNameProvider.notifier).state = value,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: productName.trim().isEmpty ? null : _onSearch,
              child: const Text('Buscar calorias'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _historyBox.listenable(),
                builder: (context, Box<MessageHistory> box, _) {
                  final history = box.values.toList().reversed.toList();

                  if (history.isEmpty) {
                    return const Center(child: Text('Nenhum histórico ainda'));
                  }

                  return ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        title: Text(item.question),
                        subtitle: item.answer.isNotEmpty ? Text(item.answer) : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            box.deleteAt(box.length - 1 - index);
                          },
                        ),
                        onTap: () {
                          _updateText(item.question);
                          Navigator.pushNamed(context, '/result', arguments: item.question);
                        },
                      );
                    },
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
