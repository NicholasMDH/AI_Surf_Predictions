import 'package:flutter/foundation.dart';

@immutable
class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.content,
    required this.isUser,
    String? id,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  Message copyWith({
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return Message(
      id: id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.content == content &&
        other.isUser == isUser &&
        other.timestamp == timestamp &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      content,
      isUser,
      timestamp,
      status,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  error,
  delivered,
  seen
}