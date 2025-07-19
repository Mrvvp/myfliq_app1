class ChatParams {
  final int senderId;
  final int receiverId;

  const ChatParams({required this.senderId, required this.receiverId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatParams &&
          runtimeType == other.runtimeType &&
          senderId == other.senderId &&
          receiverId == other.receiverId;

  @override
  int get hashCode => senderId.hashCode ^ receiverId.hashCode;
}
