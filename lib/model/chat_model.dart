import 'package:intl/intl.dart';

class ChatMessage {
  final int senderId;
  final int receiverId;
  final int messageId; // renamed for clarity
  final String message;
  final String sentAt;
  final String? senderName;
  final String? senderImage;
  final String? viewedAt;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.sentAt,
    required this.messageId,
    this.senderName,
    this.senderImage,
    this.viewedAt,
  });

  factory ChatMessage.fromJapx(
    Map<String, dynamic> json,
    Map<String, dynamic>? includedSender,
  ) {
    return ChatMessage(
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      message: json['message'] ?? '',
      sentAt: json['sent_at'] ?? '',
      messageId: int.tryParse(json['id'].toString()) ?? 0,
      senderName: includedSender?['attributes']?['name'],
      senderImage: includedSender?['attributes']?['profile_photo_url'],
      viewedAt: json['viewed_at'],
    );
  }
}

// Extension for formatted time
extension ChatMessageTimeFormat on ChatMessage {
  String get sentAtFormatted => _formatTime(sentAt);
  String get viewedAtFormatted =>
      viewedAt != null ? _formatTime(viewedAt!) : '';

  String _formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('hh:mm a').format(date); // e.g., 03:45 PM
    } catch (_) {
      return isoString;
    }
  }
}
