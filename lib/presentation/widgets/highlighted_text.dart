import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.currentMatchOffset,
  });

  final String text;
  final String query;
  final int? currentMatchOffset;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return SelectableText(text);

    final lower = text.toLowerCase();
    final q = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lower.indexOf(q, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      final isCurrent =
          (currentMatchOffset != null && index == currentMatchOffset);

      spans.add(
        TextSpan(
          text: text.substring(index, index + q.length),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            backgroundColor: isCurrent
                ? const Color(0xFFFFD54F)
                : const Color(0xFFFFF59D),
          ),
        ),
      );

      start = index + q.length;
    }

    return SelectableText.rich(
      TextSpan(children: spans, style: DefaultTextStyle.of(context).style),
    );
  }
}
