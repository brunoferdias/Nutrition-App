// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageHistoryAdapter extends TypeAdapter<MessageHistory> {
  @override
  final int typeId = 0;

  @override
  MessageHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageHistory(
      question: fields[0] as String,
      answer: fields[1] as String,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MessageHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.answer)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
