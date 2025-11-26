import 'package:flutter/material.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final double? height;

  const BasicAppButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(height ?? 80),
          backgroundColor: disabled
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)
              : null,
          foregroundColor: disabled ? Theme.of(context).disabledColor : null,
        ),
        child: Opacity(
          opacity: disabled ? 0.7 : 1.0,
          child: Text(title, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
