///
/// Composant de l'animation d'acceptation
///

import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";

import '../../../controllers/controllers.dart';

class AnimationAcceptation extends StatefulWidget {
  const AnimationAcceptation({
    required this.onFinish,
    this.delayAfterFinish = 5,
    this.width,
    this.height,
    super.key,
  });

  ///
  /// Fonction de rappel en fin d'animation
  ///
  final VoidCallback onFinish;

  ///
  /// Nombre de seconde d'attente en fin d'animation pour appeler le callback
  ///
  final int delayAfterFinish;

  ///
  /// Dimension largeur
  ///
  final double? width;

  ///
  /// Dimension hauteur
  ///
  final double? height;

  @override
  State<AnimationAcceptation> createState() => _AnimationAcceptationState();
}

class _AnimationAcceptationState extends State<AnimationAcceptation> {
  // timer de fin de procédure
  Timer? timeToLeave;

  @override
  void initState() {
    super.initState();
    // timeToLeave = Timer(Duration(seconds: widget.delayAfterFinish), () => widget.onFinish());
  }

  @override
  void dispose() {
    timeToLeave?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // dimension de l'image
    double? currentHeight = widget.height;
    if (currentHeight != null) {
      currentHeight *= 0.78;
    }

    // construction du logo
    Widget logo = SizedBox(
      height: currentHeight,
      child: Image.asset("assets/images/components/caddy-rouge.png",
          fit: BoxFit.contain),
    );

    // animation
    return logo
        .animate()
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .scale(duration: 400.ms, curve: Curves.easeOut)
        .callback(callback: (_) => SoundFx.playSuccess())
        .then()
        .shimmer(duration: 900.ms)
        .then(delay: widget.delayAfterFinish.ms)
        .moveY(end: -200, duration: 400.ms, curve: Curves.easeOut)
        .fadeOut(duration: 150.ms, curve: Curves.easeOut)
        .callback(delay: 100.ms, callback: (_) => widget.onFinish());
  }
}
