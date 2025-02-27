///
/// Création d'un bouton avec une icone
///

import 'package:flutter/material.dart';

import '../../config/config.dart';

///
/// Controleur du bouton custom icon
///
class CustomIconButtonController {
  CustomIconButtonState? _state;

  // Associe l'état du bouton au contrôleur
  void attach(CustomIconButtonState state) {
    _state = state;
  }

  // Détache le contrôleur lorsque le bouton est supprimé
  void detach() {
    _state = null;
  }

  // Méthode pour activer le bouton à distance
  Future<void> activateButton() async {
    if (_state != null) {
      await _state!.onPressedActivate();
    }
  }
}

///
/// Objet de création d'un bouton ou zone de saisie avec une icône et
/// animation lors de la validation
///
class CustomIconButton extends StatefulWidget {
  const CustomIconButton({
    super.key,
    this.controller,
    this.text,
    this.child,
    required this.icon,
    this.iconSubmitAnimation = true,
    this.onActionButton,
    this.onActionButtonDelay = 500,
    this.onActionButtonValidator,
    this.textStyle,
    this.iconBackgroundColor = Colors.grey,
    this.textBackgroundColor = Colors.white,
    this.width = 220.0,
    this.height = 40.0,
    this.showGlowBorder = false,
    this.borderRadius = 10.0,
    this.textFieldEnabled = true,
    this.textFieldPadding,
    this.textFieldHintText,
    this.textFieldStyle,
    this.textFieldController,
    this.textFieldOnChanged,
    this.textFieldOnBeforeSubmitted,
  }) : assert(width >= 100.0 && height >= 30.0,
            "width and height must be greater than 100 and 30");

  ///
  /// Controleur du bouton
  ///
  final CustomIconButtonController? controller;

  ///
  /// Contenu du label sous forme de widget
  ///
  final Widget? child;

  ///
  /// label du bouton
  ///
  final String? text;

  ///
  /// Style du label
  ///
  final TextStyle? textStyle;

  ///
  /// Couleur de fond du label
  ///
  final Color textBackgroundColor;

  ///
  /// Icon du bouton
  ///
  final Icon icon;

  ///
  /// Couleur de fond de l'icône
  ///
  final Color iconBackgroundColor;

  ///
  /// Option : animation de l'icône en cas de click
  ///
  final bool iconSubmitAnimation;

  ///
  /// Champ texte : activation
  ///
  final bool textFieldEnabled;

  ///
  /// Champ texte : padding de la zone de texte
  ///
  final EdgeInsets? textFieldPadding;

  ///
  /// Champ texte : texte Hint
  ///
  final String? textFieldHintText;

  ///
  /// Champ texte : style du champ
  ///
  final TextStyle? textFieldStyle;

  ///
  /// Champ texte : contrôleur de flux
  ///
  final TextEditingController? textFieldController;

  ///
  /// Champ texte : juste avant la submission du formulaire
  ///
  final ValueChanged<String>? textFieldOnBeforeSubmitted;

  ///
  /// Champ texte : onChanged
  /// doit retourner la valeur
  ///
  final String? Function(String value)? textFieldOnChanged;

  ///
  /// Dimensions du bouton
  ///
  final double width;

  ///
  /// Dimensions du bouton
  ///
  final double height;

  ///
  /// Option : affichage d'une lueur autour du bouton
  ///
  final bool showGlowBorder;

  ///
  /// Rayon des coins du bouton
  ///
  final double borderRadius;

  ///
  /// Action du bouton
  ///
  final Future<void> Function()? onActionButton;

  ///
  /// Option : temps de latence de l'animation de l'icône en cas de click (en millisecondes)
  ///
  final int onActionButtonDelay;

  ///
  /// Outils de validation extérieur de l'action avant l'activation du bouton
  /// et de la fonction [onActionButton]
  ///
  final bool Function()? onActionButtonValidator;

  @override
  State<CustomIconButton> createState() => CustomIconButtonState();
}

class CustomIconButtonState extends State<CustomIconButton>
    with TickerProviderStateMixin {
  // animation pour la rotation du refresh-icon
  late AnimationController _controllerRefreshIcon;
  late Animation<double> _animationRefreshIcon;

  // gestion des icônes
  late Icon iconRefresh;
  late Icon iconCurrentShow;

  // couleurs
  late Color iconBackgroundColor;
  late Color textBackgroundColor;
  late TextStyle? textStyle;
  late bool textFieldEnabled;
  late TextStyle? textFieldStyle;

  // indique si une action est en cours de réalisation pour bloquer
  // les clics intempestifs
  bool isActionProccessing = false;

  @override
  void initState() {
    super.initState();

    // on associe le controleur au bouton
    widget.controller?.attach(this);

    // test de l'exécution du callback
    iconBackgroundColor = widget.iconBackgroundColor;
    textBackgroundColor = widget.textBackgroundColor;
    textStyle = widget.textStyle;
    textFieldEnabled = widget.textFieldEnabled;
    textFieldStyle = widget.textFieldStyle;
    if (widget.onActionButton == null || textFieldEnabled == false) {
      // désactivation du bouton
      iconBackgroundColor = Colors.grey.shade700;
      textBackgroundColor = Colors.grey.shade600;
      textStyle = textStyle?.copyWith(color: Colors.grey.shade800) ??
          TextStyle(color: Colors.grey.shade800);
      textFieldEnabled = false;
      textFieldStyle = textFieldStyle?.copyWith(color: Colors.grey.shade500) ??
          TextStyle(color: Colors.grey.shade500);
    }

    // gestion des icônes
    iconRefresh = Icon(
      Icons.refresh,
      color: widget.icon.color,
      size: widget.icon.size,
    );
    iconCurrentShow = widget.icon;

    // animations
    _controllerRefreshIcon = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        // si on arrive en fin d'animation on reset
        if (status == AnimationStatus.completed) {
          _controllerRefreshIcon.repeat();
        }
      });
    _animationRefreshIcon = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _controllerRefreshIcon,
        curve: Curves.easeInOut, // Courbe d'accélération fluide
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _controllerRefreshIcon.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    // erreur de changement d'état après un dispose ou avant un initState
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    // choix du label à afficher
    Widget childInside;
    if (widget.child != null) {
      // un widget dans le bouton
      childInside = widget.child!;
    } else if (widget.textFieldHintText != null) {
      // champ texte d'édition
      childInside = Padding(
        padding: widget.textFieldPadding ?? const EdgeInsets.all(0.0),
        child: TextField(
          controller: widget.textFieldController,
          autocorrect: false,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.textFieldHintText,
            hintStyle: textFieldStyle,
          ),
          style: textFieldStyle,
          textAlign: TextAlign.start,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          enabled: textFieldEnabled,
          onSubmitted: (value) async {
            if (widget.textFieldOnBeforeSubmitted != null) {
              widget.textFieldOnBeforeSubmitted!(value);
            }
            await onPressedActivate();
          },
          onChanged: (String value) {
            // initialisation
            String text = value;

            // application de la fonction utilisateur
            if (widget.textFieldOnChanged != null) {
              text = widget.textFieldOnChanged!(value) ?? value;
            }

            // traitement du curseur notamment
            // en effet, le textfield sur l'application surligne tout le texte à
            // chaque saisie donc on a à chaque fois que le dernier caractère !
            if (widget.textFieldController != null) {
              final cursorPosition =
                  widget.textFieldController!.selection.base.offset;
              widget.textFieldController!.value =
                  widget.textFieldController!.value.copyWith(
                text: text,
                selection: TextSelection.collapsed(
                  offset: cursorPosition >= text.length
                      ? text.length
                      : cursorPosition,
                ),
              );
            }
          },
        ),
      );
    } else {
      // Label simple
      childInside = Text(
        widget.text ?? "Bouton",
        textAlign: TextAlign.center,
        style: textStyle,
      );
    }

    // Design
    return InkWell(
      onTap: (widget.onActionButton == null)
          ? null
          : () async => await onPressedActivate(),
      child: Container(
        padding: const EdgeInsets.all(0.0),
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: textBackgroundColor,
          boxShadow: [
            if (widget.showGlowBorder) ...[
              BoxShadow(
                color: textBackgroundColor.withOpacity(.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
          ],
        ),
        child: Row(
          children: <Widget>[
            LayoutBuilder(builder: (context, constraints) {
              return Container(
                height: constraints.maxHeight,
                width: constraints.maxHeight,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: RotationTransition(
                  turns: _animationRefreshIcon,
                  child: iconCurrentShow,
                ),
              );
            }),
            Expanded(
              child: childInside,
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// Activation du submit pour le textfield ou le bouton
  ///
  Future onPressedActivate() async {
    // vérification d'usage
    if (!textFieldEnabled) {
      return;
    }

    // validation de l'action si disponible
    if (widget.onActionButtonValidator != null &&
        !widget.onActionButtonValidator!()) {
      // annulation de l'action
      return;
    }

    // l'action est déjà en cours ?
    if (isActionProccessing) {
      return;
    }
    isActionProccessing = true;

    // désactivation du champ formulaire pendant traitement
    if (widget.textFieldEnabled) {
      setState(() {
        textFieldEnabled = false;
      });
    }

    // Début d'animation
    if (widget.iconSubmitAnimation) {
      setState(() {
        iconCurrentShow = iconRefresh;
      });
      _controllerRefreshIcon.forward(from: 0);

      // latence
      await Future.delayed(
          Duration(milliseconds: widget.onActionButtonDelay), () {});
    }

    // traitement extérieur
    if (widget.onActionButton != null) {
      try {
        await widget.onActionButton!();
      } catch (e) {
        ToolsConfigApp.logger.e("custom_icon_button: onActionButton: $e");
      }
    }

    // fin d'animation
    if (widget.iconSubmitAnimation) {
      setState(() {
        iconCurrentShow = widget.icon;

        // reinitialisation de l'animation
        _controllerRefreshIcon.reset();
      });
    }

    // activation du champ formulaire
    if (widget.textFieldEnabled) {
      setState(() {
        textFieldEnabled = true;
      });
    }

    // on relâche le verrou
    isActionProccessing = false;
  }
}
