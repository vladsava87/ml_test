import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 3 / 4, // tweak as you like
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(color: Colors.black12, child: child),
          ),
        ),
      ],
    );
  }
}
