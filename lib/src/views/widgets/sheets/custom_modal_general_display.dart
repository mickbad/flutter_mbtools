import 'package:flutter/material.dart';
import 'package:mbtools/src/views/widgets/sheets/custom_modal_sheet_abstract.dart';

///
/// Construction d'une fenêtre personnalisée General Display
///
// ignore: must_be_immutable
class CustomModalGeneralDisplay extends CustomModalSheetAbstract {
  CustomModalGeneralDisplay({
    super.key,
    super.controller,
    super.displayTitle = true,
    super.defaultCloseButtonColor,
    super.backgroundColorTitleBox,
    super.heightTitleBox,
    super.paddingTitleBox,
    super.title,
    super.titleStyle,
    super.titleWidgetLeading,
    super.titleWidgetTrailing,
    super.displayTrailingCloseButton = true,
    super.childPadding,
    required super.child,
    this.borderRadiusModal,
    required this.dialogWidth,
    required this.dialogHeight,
    this.heightActionButtons = 40,
    this.actionButtons,
  });

  ///
  /// Radius de la fenêtre modale
  ///
  final BorderRadius? borderRadiusModal;

  ///
  /// Dimensions des compsants (contenu et boutons du bas)
  ///
  final double dialogWidth;
  final double dialogHeight;

  ///
  /// Création d'une zone d'actions bouton en bas du dialogue
  ///
  final double heightActionButtons;
  final List<Widget>? actionButtons;

  @override
  State<CustomModalGeneralDisplay> createState() =>
      _CustomModalGeneralDisplayState();
}

class _CustomModalGeneralDisplayState extends State<CustomModalGeneralDisplay> {
  @override
  void initState() {
    super.initState();

    // Enregistrer le contexte dans le controller si fourni
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller != null) {
        widget.controller!.setDialogContext(context);
      }
    });
  }

  @override
  void dispose() {
    widget.controller?.clearContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // étude de la place de la barre titre
    double heightTitleBoxInternal = 0;
    if (widget.displayTitle) {
      heightTitleBoxInternal = widget.heightTitleBox;
    }

    // étude de la place des actions buttons
    double heightActionButtonInternal = 0;
    if (widget.actionButtons != null && widget.actionButtons!.isNotEmpty) {
      heightActionButtonInternal = widget.heightActionButtons;
    }

    // affichage de l'écran
    return Stack(
      children: [
        // Affichage en tête de la zone de la barre titre
        if (widget.displayTitle) ...[
          Align(
            alignment: Alignment.topCenter,
            child: widget.customCreateTitleBar(
              context,
              width: widget.dialogWidth,
              height: heightTitleBoxInternal,
              borderRadius: widget.borderRadiusModal,
              padding: widget.paddingTitleBox,
            ),
          ),
        ],

        // Contenu
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: widget.dialogWidth,
            height: widget.dialogHeight -
                heightTitleBoxInternal -
                heightActionButtonInternal,
            margin: EdgeInsets.only(top: heightTitleBoxInternal),
            decoration: BoxDecoration(
              // color: appOrderDetailsBackgroundColor,
              borderRadius: widget.borderRadiusModal,
            ),
            child: Padding(
              padding: widget.childPadding ?? const EdgeInsets.all(8.0),
              child: SingleChildScrollView(child: widget.child),
            ),
          ),
        ),

        // boutons actions
        if (widget.actionButtons != null &&
            widget.actionButtons!.isNotEmpty) ...[
          Align(
            alignment: Alignment.bottomCenter,
            child: widget.customCreateFooter(
              context,
              width: widget.dialogWidth,
              height: heightActionButtonInternal,
              borderRadius: widget.borderRadiusModal,
              widgets: widget.actionButtons!,
            ),
          ),
        ],
      ],
    );
  }
}
