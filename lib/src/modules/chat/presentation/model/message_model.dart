class Message {
  final String text;
  final bool isMe;
  final String? status;

  const Message({required this.text, required this.isMe, this.status});
}
