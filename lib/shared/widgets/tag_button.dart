import 'package:flutter/material.dart';

class TagButton extends StatelessWidget {
  const TagButton({
    super.key,
    required this.text,
    required this.color,
    this.isClickable = false,
    this.onTap,
  });

  final String text;
  final Color color;
  final bool isClickable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border:
              isClickable && text.contains('+')
                  ? Border.all(color: Colors.grey.shade400, width: 1)
                  : null,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
