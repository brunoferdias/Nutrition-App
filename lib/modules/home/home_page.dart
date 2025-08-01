// IMPORTS
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../app/constants.dart';
import '../../core/models/message_history.dart';
import '../../core/providers/message_provider.dart';
import '../result/result_page.dart';

class HomePage extends StatefulWidget {
  final apiKey;
  const HomePage({super.key, required this.apiKey});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  void _updateText(BuildContext context, String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    Provider.of<MessageProvider>(context, listen: false).setProductName(text);
  }

  Future<void> _onSearch(BuildContext context) async {
    final productName = Provider.of<MessageProvider>(
      context,
      listen: false,
    ).productName.trim();
    if (productName.isEmpty) return;

    final alreadyExists = _historyBox.values.any(
      (item) => item.question.toLowerCase() == productName.toLowerCase(),
    );
    if (!alreadyExists) {
      final historyItem = MessageHistory(
        question: productName,
        answer: '',
        date: DateTime.now(),
      );
      try {
        await _historyBox.add(historyItem);
      } catch (e) {
        debugPrint('Erro ao salvar no Hive: $e');
      }
    }

    if (!mounted) return;
    Navigator.of(context).push(_createSlideRoute(productName));
  }

  Route _createSlideRoute(String productName) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ResultPage(productName: productName, apiKey: widget.apiKey),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0); // from bottom
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productName = Provider.of<MessageProvider>(context).productName;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: const Text(
            'NutriScan AI',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Digite o Alimento ou Bebida',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  suffixIcon: IconButton(
                    onPressed: () {
                      _controller.clear();
                    },
                    icon: Icon(Icons.cancel_outlined, color: Colors.white24),
                  ),
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => Provider.of<MessageProvider>(
                  context,
                  listen: false,
                ).setProductName(value),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: productName.trim().isEmpty
                      ? null
                      : () => _onSearch(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Buscar calorias',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ✅ DIVISOR ELEGANTE
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Histórico',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                ],
              ),
              const SizedBox(height: 12),

              // ✅ HISTÓRICO
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _historyBox.listenable(),
                  builder: (context, Box<MessageHistory> box, _) {
                    final history = box.values.toList().reversed.toList();
                    if (history.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum histórico ainda',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final formattedDate = DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(item.date);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(
                              item.question,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              formattedDate,
                              style: const TextStyle(color: Colors.white54),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                box.deleteAt(
                                  box.length - 1 - index,
                                ); // reversed
                              },
                            ),
                            onTap: () {
                              _updateText(context, item.question);
                              _onSearch(context);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
