import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

class WidgetChatInput extends StatefulWidget {
  final ValueChanged<String>? onSend;

  const WidgetChatInput({
    super.key,
    this.onSend,
  });

  @override
  State<WidgetChatInput> createState() => _WidgetChatInputState();
}

class _WidgetChatInputState extends State<WidgetChatInput> {
  final _controller = TextEditingController();

  void _handleSend(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    widget.onSend?.call(trimmed);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      color: ColorName.white,
      child: Row(
        children: [
          // Nút Add
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ColorName.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: ColorName.white, size: 24),
          ),
          const SizedBox(width: 8),

          // Ô nhập
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: ColorName.grey100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSend,
                decoration: const InputDecoration(
                  hintText: 'Typing...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(bottom: 10),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Nút gửi
          GestureDetector(
            onTap: () => _handleSend(_controller.text),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: ColorName.mint.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: ColorName.mint, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
