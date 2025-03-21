///
/// https://github.com/MohamedAbd0/stroke_text/
///
library;

import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  final String text;
  final double strokeWidth;
  final Color textColor;
  final Color strokeColor;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const StrokeText(
    this.text, {
    Key? key,
    this.strokeWidth = 0,
    this.strokeColor = Colors.black,
    this.textColor = Colors.white,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle? styleStroke;
    if (style != null) {
      styleStroke = style!.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = strokeColor,
      );
    }

    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ).merge(styleStroke),
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        ),
        Text(
          text,
          style: TextStyle(color: textColor).merge(style),
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        ),
      ],
    );
  }
}
