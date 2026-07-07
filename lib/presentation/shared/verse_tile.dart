import 'package:flutter/material.dart';
import '../../domain/entities/verse.dart';

class VerseTile extends StatelessWidget {
  final Verse verse;
  final String? highlightColor;
  final bool showActions;
  final double fontSize;
  final String fontFamily;
  final double margin;
  final void Function(Verse verse)? onTap;
  final void Function(Verse verse)? onLongPress;

  const VerseTile({
    super.key,
    required this.verse,
    this.highlightColor,
    this.showActions = true,
    this.fontSize = 18,
    this.fontFamily = 'Inter',
    this.margin = 16,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = highlightColor != null
        ? Color(int.parse(highlightColor!.replaceFirst('#', '0xFF')))
        : null;

    return InkWell(
      onTap: () => onTap?.call(verse),
      onLongPress: () => onLongPress?.call(verse),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: margin, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 36,
              child: Text(
                '${verse.verse}',
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize * 0.75,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: bgColor != null
                    ? BoxDecoration(
                        color: bgColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                padding: bgColor != null
                    ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
                    : null,
                child: Text(
                  verse.text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: fontFamily,
                    height: 1.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
