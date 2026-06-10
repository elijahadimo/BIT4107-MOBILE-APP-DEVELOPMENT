import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];

  List<Message> getMessagesBetween(String userId1, String userId2) {
    return _messages.where((m) => 
      (m.senderId == userId1 && m.receiverId == userId2) ||
      (m.senderId == userId2 && m.receiverId == userId1)
    ).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void sendMessage(String senderId, String receiverId, String text) {
    final message = Message(
      id: const Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
    notifyListeners();
  }
}
