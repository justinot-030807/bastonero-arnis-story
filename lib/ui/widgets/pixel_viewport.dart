// lib/ui/widgets/pixel_viewport.dart
// Integer-scaling pixel viewport (240px virtual width).

import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/balance.dart';

class PixelViewport extends StatelessWidget {
  final Widget child;

  const PixelViewport({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Integer scaling factor (e.g. 1x on 240px, 2x on 480px, 3x on 720px, 4x on 1080px)
        final rawScale = screenWidth / Balance.virtualWidth;
        final integerScale = max(1, rawScale.floor());

        final scaledWidth = Balance.virtualWidth * integerScale;

        return Container(
          color: const Color(0xFF0F172A),
          child: Center(
            child: SizedBox(
              width: scaledWidth > screenWidth ? screenWidth : scaledWidth,
              height: screenHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
