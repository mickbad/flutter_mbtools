///
/// Animation d'une image pour le fond d'écran
///

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:motion/motion.dart';

import '../../config/config.dart';

///
/// Gestion du contrôleur pour le widget fond d'écran
///
class BackgroundOpenLinkController extends ChangeNotifier {
  final double zoomFactor;
  final int duration;

  // activation de la nouvelle animation
  bool shouldStartAnimation = false;

  // fonction de rappel pour le changement de page en fin d'animation
  VoidCallback? onFinished;

  ///
  /// Constructeur
  ///
  BackgroundOpenLinkController({
    this.zoomFactor = 12.0,
    this.duration = 2000,
  });

  ///
  /// Lancement de l'animation de changement de page
  ///
  void goto(String pageUrl,
      {bool replaceNamed = false, bool animation = true}) {
    // vérification
    assert(pageUrl.isNotEmpty);
    if (shouldStartAnimation) {
      return;
    }

    // pas d'animation et redirection immédiate
    if (!animation) {
      openInternalLink(pageUrl, replaceNamed: replaceNamed);
      return;
    }

    // préparation de l'animation
    onFinished = () => openInternalLink(pageUrl, replaceNamed: replaceNamed);
    shouldStartAnimation = true;

    // log
    ToolsConfigApp.logger.t(
        "[BackgroundOpenLinkController] Lancement de l'animation de changement de page vers $pageUrl");
    notifyListeners();
  }

  ///
  /// Ouverture d'une nouvelle page
  ///
  void openInternalLink(String pageUrl, {bool replaceNamed = false}) {
    if (replaceNamed) {
      ToolsConfigApp.appNavigatorKey.currentState
          ?.pushReplacementNamed(pageUrl);
    } else {
      ToolsConfigApp.appNavigatorKey.currentState?.pushNamed(pageUrl);
    }
  }
}

///
/// Type d'image
///
enum BackgroundImageType {
  asset,
  file,
  network,
}

///
/// Widget fond d'écran
///
class BackgroundImageAnimated extends StatefulWidget {
  // propriétés
  final double width;
  final double height;

  // fond
  final Color background;

  // image
  final String image;
  final BackgroundImageType imageType;
  final BoxFit imageFit;
  final double imageZoomFirst;
  final double imageZoomLast;

  // animation résiduelle
  final bool animate;
  final int animationDuration;

  // utilisation du plugin motion avec le gyroscope
  final bool useGyroscopeMotion;

  // création d'une animation pour finir l'animation initiale
  final BackgroundOpenLinkController? controllerOpenLink;

  // contenu du widget
  final Widget child;

  const BackgroundImageAnimated({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.background = Colors.black,
    required this.image,
    this.imageType = BackgroundImageType.asset,
    this.imageFit = BoxFit.cover,
    this.imageZoomFirst = 1.0,
    this.imageZoomLast = 1.10,
    this.animate = true,
    this.animationDuration = 10000,
    this.useGyroscopeMotion = false,
    this.controllerOpenLink,
  })  : assert(imageZoomLast >= imageZoomFirst),
        assert(imageZoomFirst > 0.0),
        assert(animationDuration > 0.0);

  @override
  _BackgroundImageAnimated createState() => _BackgroundImageAnimated();
}

class _BackgroundImageAnimated extends State<BackgroundImageAnimated>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;

  AnimationController? _controllerOutInterface;
  Animation<double>? _animationOutInterface;

  // observers
  bool isAnimationEnabled = true;
  bool isAnimationOutInterface =
      false; // l'animation est active pour la sortie de l'interface

  @override
  void initState() {
    super.initState();

    // options
    isAnimationEnabled = widget.animate;

    // animation de l'image résiduelle
    initNormalAnimation();

    // gestion du contrôleur de fin de widget (vers un lien)
    widget.controllerOpenLink?.addListener(() {
      // vérification si l'animation doit être lancée pour la page suivante
      if (widget.controllerOpenLink!.shouldStartAnimation) {
        // récupération du zoom courant
        final current = _animation.value;

        // arrêt du zoom actuel
        _controller?.dispose();
        _controller = null;

        // recréation de l'animation
        _controllerOutInterface = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.controllerOpenLink!.duration),
        );

        // progression animation
        final CurvedAnimation curve = CurvedAnimation(
          parent: _controllerOutInterface!,
          curve: Curves.easeInCubic,
        );

        _animationOutInterface = Tween<double>(
                begin: current,
                end: (current * widget.controllerOpenLink!.zoomFactor).abs())
            .animate(curve);

        // on active l'animation de sortie
        setState(() {
          isAnimationOutInterface = true;
        });

        // démarrage et redirection
        _controllerOutInterface!.forward().whenComplete(() {
          ToolsConfigApp.logger
              .t("[BackgroundImageAnimated] fin de l'animation de lancement");

          // animation de l'image résiduelle
          initNormalAnimation();
          widget.controllerOpenLink!.shouldStartAnimation = false;

          if (widget.controllerOpenLink!.onFinished != null) {
            widget.controllerOpenLink!.onFinished!();
          }
        });
      }
      setState(() {});
    });
  }

  void initNormalAnimation() {
    // option
    setState(() {
      isAnimationOutInterface = false;
    });

    // animation de l'image résiduelle
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDuration),
    );

    // progression animation
    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );

    // création des bornes des valeurs
    _animation =
        Tween<double>(begin: widget.imageZoomFirst, end: widget.imageZoomLast)
            .animate(curve);

    // activation de l'animation
    if (widget.animate) {
      _controller!.repeat(reverse: true);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // vérification de l'état de l'animation uniquement en mode normal
    // sans sortie de l'interface
    if (!isAnimationOutInterface && isAnimationEnabled != widget.animate) {
      // changement d'état de l'animation
      isAnimationEnabled = widget.animate;
      if (widget.animate) {
        _controller?.repeat(reverse: true);
      } else {
        _controller?.stop();
      }
    }

    // configuration de l'image à afficher
    Widget imageContainer = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: widget.imageFit,
        ),
      ),
    );
    if (widget.useGyroscopeMotion) {
      // détection de la permission d'utiliser le gyroscope
      if (Motion.instance.isPermissionRequired &&
          !Motion.instance.isPermissionGranted) {
        Motion.instance.requestPermission();
      }

      if (!Motion.instance.isPermissionRequired ||
          Motion.instance.isPermissionGranted) {
        // utilisation du mode gyroscope pour faire une sorte de parallaxe
        imageContainer = Transform.scale(
          // augmentation du zoom pour que l'image prenne bien toute la largeur
          // et la hauteur de l'écran sans bord noir
          scale: 1.03,
          child: Motion(
            filterQuality: FilterQuality.medium,
            glare: null,
            child: imageContainer,
          ),
        );
      }
    }

    // affichage
    return Stack(children: [
      Container(
        width: widget.width,
        height: widget.height,
        color: widget.background,
      ),

      AnimatedBuilder(
        animation:
            isAnimationOutInterface ? _animationOutInterface! : _animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scale: isAnimationOutInterface
                ? _animationOutInterface!.value
                : widget.animate
                    ? _animation.value
                    : widget.imageZoomFirst,
            child: imageContainer,
          );
        },
      ),

      // contenu
      widget.child,
    ]);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controllerOutInterface?.dispose();
    super.dispose();
  }

  // image d'arrière plan
  ImageProvider get imageProvider {
    switch (widget.imageType) {
      case BackgroundImageType.asset:
        return AssetImage(widget.image);

      case BackgroundImageType.file:
        return FileImage(File(widget.image));

      case BackgroundImageType.network:
        return NetworkImage(widget.image);

      // default:
      //   // erreur
      //   throw Exception('image must not be null');
    }
  }
}
