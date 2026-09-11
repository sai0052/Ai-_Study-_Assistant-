import 'package:equatable/equatable.dart';

enum MessageSender { user, ai }

class ChatMessageEntity extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, text, sender, timestamp];
}
