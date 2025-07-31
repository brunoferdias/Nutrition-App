import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'core/models/message_history.dart';
import 'modules/home/home_page.dart';
import 'modules/result/result_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter();
  Hive.registerAdapter(MessageHistoryAdapter());
  await Hive.openBox<MessageHistory>('historyBox');
  runApp(const ProviderScope(child: MyApp()));
}
final openAIKey = dotenv.env['OPENAI_API_KEY'];
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => const HomePage(),
        '/result': (context) {
          final product = ModalRoute.of(context)!.settings.arguments as String;
          return ResultPage(productName: product, apiKey: openAIKey!);
        }
      },
    );
  }
}
