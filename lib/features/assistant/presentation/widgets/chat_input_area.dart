import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

class ChatInputArea extends StatelessWidget {
  const ChatInputArea({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: palette.background,
        border: Border(
          top: BorderSide(color: palette.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(
                  color: palette.onBackground,
                  fontFamily: 'Janna',
                  fontSize: 16,
                ),
                cursorColor: palette.primary,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'اكتب سؤالك هنا...',
                  hintStyle: TextStyle(
                    color: palette.onBackground.withValues(alpha: 0.4),
                    fontFamily: 'Janna',
                  ),
                  filled: true,
                  fillColor: palette.onBackground.withValues(alpha: 0.07),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: palette.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(color: palette.primary, width: 1.3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.primary.withValues(alpha: 0.15),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.4),
                ),
              ),
              child: IconButton(
                onPressed: isLoading ? null : onSend,
                icon: Icon(
                  Icons.send_rounded,
                  color: isLoading
                      ? palette.primary.withValues(alpha: 0.4)
                      : palette.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
