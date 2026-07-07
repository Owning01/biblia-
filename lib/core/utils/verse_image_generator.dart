import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class VerseImageGenerator {
  static Future<Uint8List> generate({
    required String verseText,
    required String reference,
    String? fontFamily,
    double fontSize = 24,
    Color bgColor = const Color(0xFF1A1A2E),
    Color textColor = const Color(0xFFFFFFFF),
    Color refColor = const Color(0xFFB0B0B0),
  }) async {
    final controller = ScreenshotController();
    final widget = _VerseShareCard(
      verseText: verseText,
      reference: reference,
      fontFamily: fontFamily,
      fontSize: fontSize,
      bgColor: bgColor,
      textColor: textColor,
      refColor: refColor,
    );

    final result = await controller.captureFromWidget(widget, pixelRatio: 3.0);
    return result;
  }
}

class _VerseShareCard extends StatelessWidget {
  final String verseText;
  final String reference;
  final String? fontFamily;
  final double fontSize;
  final Color bgColor;
  final Color textColor;
  final Color refColor;

  const _VerseShareCard({
    required this.verseText,
    required this.reference,
    this.fontFamily,
    required this.fontSize,
    required this.bgColor,
    required this.textColor,
    required this.refColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1080,
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor, Color.lerp(bgColor, Colors.black, 0.3)!],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            verseText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: fontSize,
              color: textColor,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            height: 2,
            width: 80,
            color: refColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 24),
          Text(
            reference,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: fontSize * 0.55,
              color: refColor,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(flex: 2),
          Text(
            'Biblia',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 16,
              color: refColor.withValues(alpha: 0.5),
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
