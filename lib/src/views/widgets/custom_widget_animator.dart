
import 'dart:math' as math;

import 'package:flutter/material.dart';

///
/// Enumération des possibilités des animations sur un widget
///
enum CustomWidgetAnimatorType { flip, zoom }

///
/// Widget animation pour faire des flips/... à un widget cliquable
///
class CustomWidgetAnimator extends StatefulWidget {
  final Widget child;
  final CustomWidgetAnimatorType type;
  final double maxZoom;
  final int flips; // < 1 => infini
  final Duration duration; // durée d’un flip complet
  final Duration delayBeforeStart; // délai avant le démarrage
  final Duration delayBetween; // délai entre deux flips
  final Curve curve;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CustomWidgetAnimator({
    super.key,
    required this.child,
    this.type = CustomWidgetAnimatorType.flip,
    this.maxZoom = 1.1,
    this.flips = 1,
    this.duration = const Duration(milliseconds: 750),
    this.delayBeforeStart = const Duration(milliseconds: 1500),
    this.delayBetween = const Duration(milliseconds: 3000),
    this.curve = Curves.easeOut,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<CustomWidgetAnimator> createState() => _CustomWidgetAnimatorState();
}

class _CustomWidgetAnimatorState extends State<CustomWidgetAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isNavigating = false;
  bool _isRunning = true; // pour stopper si on quitte le widget

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    // démarrage du flip
    _startAutoFlips();
  }

  Future<void> _startAutoFlips() async {
    // pause avant
    await Future.delayed(widget.delayBeforeStart);

    if (widget.flips < 0) {
      // 🔁 infini
      while (_isRunning) {
        await _controller.forward(from: 0);
        await Future.delayed(widget.delayBetween);
      }
    } else if (widget.flips > 0) {
      // 🔁 nombre fini de flips
      for (int i = 0; i < widget.flips && _isRunning; i++) {
        await _controller.forward(from: 0);
        if (i < widget.flips - 1) {
          await Future.delayed(widget.delayBetween);
        }
      }
    }
  }

  Future<void> _handleTap(BuildContext context) async {
    if (_isNavigating || widget.onTap == null) return;

    _isNavigating = true;

    // 🎬 lancer 1 flip complet
    await _controller.forward(from: 0);

    if (mounted) {
      widget.onTap!();
    }

    _isNavigating = false;
  }

  Future<void> _handleLongTap(BuildContext context) async {
    if (_isNavigating || widget.onLongPress == null) return;

    _isNavigating = true;

    // 🎬 lancer 1 flip complet
    await _controller.forward(from: 0);

    if (mounted) {
      widget.onLongPress!();
    }

    _isNavigating = false;
  }

  @override
  void dispose() {
    _isRunning = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///
    ///  Choix de l'animation
    ///
    Widget content = const SizedBox.shrink();
    if (widget.type == CustomWidgetAnimatorType.flip) {
      content = AnimatedBuilder(
        animation: _animation,
        builder: (_, child) {
          final angle = _animation.value * 2 * math.pi;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(angle),
            child: child,
          );
        },
        child: widget.child,
      );
    } else if (widget.type == CustomWidgetAnimatorType.zoom) {
      content = AnimatedBuilder(
        animation: _animation,
        builder: (_, child) {
          // scale varie
          final scale =
              1.0 +
                  (widget.maxZoom - 1.0) *
                      (0.5 - (0.5 - _animation.value).abs()) *
                      2;

          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      );
    }

    if (widget.onTap != null || widget.onLongPress != null) {
      content = GestureDetector(
        onTap: () => _handleTap(context),
        onLongPress: () => _handleLongTap(context),
        child: content,
      );
    }

    return content;
  }
}
