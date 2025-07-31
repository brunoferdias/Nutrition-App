import 'package:hive/hive.dart';
part 'message_history.g.dart';

@HiveType(typeId: 0)
class MessageHistory extends HiveObject {
  @HiveField(0)
  String question;

  @HiveField(1)
  String answer;

  @HiveField(2)
  DateTime date;

  MessageHistory({
    required this.question,
    required this.answer,
    required this.date,
  });
}
