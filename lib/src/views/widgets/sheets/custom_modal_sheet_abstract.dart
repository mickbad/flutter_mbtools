import 'package:flutter/material.dart';
import 'package:mbtools/mbtools.dart';

///
/// Classe controleur pour gérer à distance la boîte de dialogue
///
class CustomModalSheetController {
  BuildContext? _dialogContext;
  BuildContext? get context => _dialogContext;

  void setDialogContext(BuildContext context) {
    _dialogContext = context;
  }

  Future<void> closeDialog() async {
    if (_dialogContext != null && Navigator.canPop(_dialogContext!)) {
      await Navigator.of(_dialogContext!).maybePop();
      _dialogContext = null;
    }
  }

  Future<void> forceClose() async {
    if (_dialogContext != null && Navigator.of(_dialogContext!).mounted) {
      await Navigator.of(_dialogContext!).maybePop();
    }
    _dialogContext = null;
  }

  void clearContext() {
    _dialogContext = null;
  }
}

///
/// Modèle abstraite des fenêtres modales
///
// ignore: must_be_immutable
abstract class CustomModalSheetAbstract extends StatefulWidget {
  ///
  /// Controlleur d'état
  ///
  final CustomModalSheetController? controller;

  ///
  /// Affichage de la zone de titre dans la fenêtre
  ///
  final bool displayTitle;

  ///
  /// couleur de l'icône de fermeture du modal
  ///
  Color? defaultCloseButtonColor;

  ///
  /// Couleur du fond de la boîte titre
  ///
  final Color? backgroundColorTitleBox;

  ///
  /// Hauteur de la boîte titre
  ///
  final double heightTitleBox;

  ///
  /// Padding de la boîte titre
  ///
  final EdgeInsets? paddingTitleBox;

  ///
  /// Affichage du titre
  ///
  final String? title;

  ///
  /// Style du titre
  ///
  final TextStyle? titleStyle;

  ///
  /// Widget Leading du titre (avant le titre)
  ///
  final List<Widget>? titleWidgetLeading;

  ///
  /// Widget Trailing du titre (après le titre)
  ///
  final List<Widget>? titleWidgetTrailing;

  ///
  /// Affichage dans le trailing de l'icône de fermeture de la fenêtre
  ///
  final bool displayTrailingCloseButton;

  ///
  /// Affichage du contenu
  ///
  final Widget child;

  ///
  /// Padding du contenu
  ///
  final EdgeInsets? childPadding;

  CustomModalSheetAbstract({
    super.key,
    this.controller,
    this.displayTitle = true,
    this.defaultCloseButtonColor,
    this.backgroundColorTitleBox,
    this.heightTitleBox = 40.0,
    this.paddingTitleBox = const EdgeInsets.only(left: 20.0, right: 20.0),
    this.title,
    this.titleStyle,
    this.titleWidgetLeading,
    this.titleWidgetTrailing,
    this.displayTrailingCloseButton = true,
    this.childPadding,
    required this.child,
  }) {
    // ajustements
    defaultCloseButtonColor ??= ToolsConfigApp.appPrimaryColor;
  }

  ///
  /// Construction d'une entête titre du dialogue
  ///
  Widget customCreateTitleBar(
    BuildContext context, {
    required double width,
    required double height,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
  }) {
    // construction de la barre
    Widget titleBar = Row(
      children: [
        // actions avant
        if (titleWidgetLeading != null) ...[
          ...titleWidgetLeading!,
          const SizedBox(
            width: 20.0,
          ),
        ],
        Expanded(
          child: Text(
            title ?? ToolsConfigApp.appName,
            style: titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // actions après
        if (titleWidgetTrailing != null) ...[
          const SizedBox(
            width: 20.0,
          ),
          ...titleWidgetTrailing!,
        ],

        if (displayTrailingCloseButton) ...[
          const SizedBox(
            width: 20.0,
          ),

          // Fermeture de la fenêtre
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.close,
              color: defaultCloseButtonColor,
            ),
          ),
        ],
      ],
    );

    // affichage finale
    return Container(
      width: width,
      height: height,

      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColorTitleBox ??
            ToolsConfigApp.appSecondaryColor.withValues(alpha: 0.90),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius?.topLeft.x ?? 5.0),
          topRight: Radius.circular(borderRadius?.topRight.x ?? 5.0),
        ),
      ),

      // titre de la fenêtre
      child: titleBar,
    );
  }

  ///
  /// Construction d'un pied de page du dialogue
  ///
  Widget customCreateFooter(
    BuildContext context, {
    required double width,
    required double height,
    BorderRadius? borderRadius,
    required List<Widget> widgets,
  }) {
    // affichage du design
    return Container(
      width: width,
      height: height,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius?.bottomLeft.x ?? 5.0),
          bottomRight: Radius.circular(borderRadius?.bottomRight.x ?? 5.0),
        ),
      ),

      // affichage des actions
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (Widget w in widgets) ...[
            Expanded(child: w),
          ],
        ],
      ),
    );
  }
}
