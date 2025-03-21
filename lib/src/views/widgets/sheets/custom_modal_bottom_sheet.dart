import 'package:flutter/material.dart';
import 'package:mbtools/mbtools.dart';
import 'package:mbtools/src/views/widgets/sheets/custom_modal_sheet_abstract.dart';

///
/// Construction d'une fenêtre personnalisée bottom sheet modal
///
// ignore: must_be_immutable
class CustomModalBottomSheet extends CustomModalSheetAbstract {
  CustomModalBottomSheet({
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
    this.initialModalSize = 0.6,
    this.minimumModalSize = 0.2,
    this.maximumModalSize = 0.9,
    required this.widthFactor,
    this.backgroundColorModal,
    this.borderRadiusModal,
  });

  ///
  /// Proportion initiale de la hauteur de la fenêtre modale sur l'écran
  ///
  final double initialModalSize;
  final double minimumModalSize;
  final double maximumModalSize;

  ///
  /// Dimension horizontale de la fenêtre
  ///
  final double widthFactor;

  ///
  /// couleur de fond de la fenêtre
  ///
  final Color? backgroundColorModal;

  ///
  /// Radius de la fenêtre modale
  ///
  final BorderRadius? borderRadiusModal;

  @override
  State<CustomModalBottomSheet> createState() => _CustomModalBottomSheetState();
}

class _CustomModalBottomSheetState extends State<CustomModalBottomSheet> {
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
    // desgin
    return DraggableScrollableSheet(
      initialChildSize: widget.initialModalSize,
      minChildSize: widget.minimumModalSize,
      maxChildSize: widget.maximumModalSize,
      builder: (_, controller) {
        return Container(
          width: MediaQuery.of(context).size.width * widget.widthFactor,
          padding: const EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            color: widget.backgroundColorModal ??
                ToolsConfigApp.appSecondaryColor.withValues(alpha: 0.70),
            borderRadius: widget.borderRadiusModal ??
                const BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                ),
          ),
          child: Stack(
            children: [
              // contenu de la fenêtre
              SingleChildScrollView(
                padding: widget.childPadding,
                child: Column(
                  children: [
                    if (widget.displayTitle) ...[
                      SizedBox(
                        height: widget.heightTitleBox,
                      ),
                    ],

                    // affichage du contenu scrollable
                    widget.child,
                  ],
                ),
              ),

              // affichage de la barre des tâche avec l'icône de fermeture de la fenêtre
              if (widget.displayTitle) ...[
                Positioned(
                  top: 0,
                  left: 0,
                  child: widget.customCreateTitleBar(
                    context,
                    width:
                        MediaQuery.of(context).size.width * widget.widthFactor,
                    height: widget.heightTitleBox,
                    borderRadius: widget.borderRadiusModal,
                    padding: widget.paddingTitleBox,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
