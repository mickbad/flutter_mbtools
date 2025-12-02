import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mbtools/mbtools.dart';
import 'package:mbtools/src/views/widgets/sheets/custom_modal_bottom_sheet.dart';
import 'package:mbtools/src/views/widgets/sheets/custom_modal_general_display.dart';

///
/// Objet de création d'une fenêtre modale dans la fenêtre principale
///

// -----------------------------------------------------------------------------
class CustomSheetModal {
  ///
  /// Affichage d'une boîte de dialogue bottom sheet
  ///
  static void bottomSheet(
    BuildContext context, {
    CustomModalSheetController? controller,
    bool displayTitle = true,
    Color? defaultCloseButtonColor,
    Color? backgroundColorTitleBox,
    double heightTitleBox = 40.0,
    EdgeInsets? paddingTitleBox =
        const EdgeInsets.only(left: 20.0, right: 20.0),
    String? title,
    TextStyle? titleStyle,
    List<Widget>? titleWidgetLeading,
    List<Widget>? titleWidgetTrailing,
    bool displayTrailingCloseButton = true,
    double widthFactor = 0.85,
    double initialModalSize = 0.6,
    double minimumModalSize = 0.2,
    double maximumModalSize = 0.9,
    Color? backgroundColorModal,
    BorderRadius? borderRadiusModal,
    EdgeInsets? childPadding,
    bool isDismissible = true,
    Widget? child,
  }) {
    // affichage de la fenêtre
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      useSafeArea: true,
      constraints: BoxConstraints(
        // maxWidth: MediaQuery.of(context).size.width * widthFactor,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      builder: (context) {
        return FractionallySizedBox(
          alignment: Alignment.topLeft,
          widthFactor: widthFactor,
          child: CustomModalBottomSheet(
            controller: controller,
            displayTitle: displayTitle,
            defaultCloseButtonColor: defaultCloseButtonColor,
            backgroundColorTitleBox: backgroundColorTitleBox,
            heightTitleBox: heightTitleBox,
            paddingTitleBox: paddingTitleBox,
            title: title,
            titleStyle: titleStyle,
            titleWidgetLeading: titleWidgetLeading,
            titleWidgetTrailing: titleWidgetTrailing,
            displayTrailingCloseButton: displayTrailingCloseButton,
            widthFactor: widthFactor,
            initialModalSize: initialModalSize,
            minimumModalSize: minimumModalSize,
            maximumModalSize: maximumModalSize,
            backgroundColorModal: backgroundColorModal,
            borderRadiusModal: borderRadiusModal,
            childPadding: childPadding,
            child: child ?? const Placeholder(),
          ),
        );
      },
    );
  }

  ///
  /// Affichage d'une boîte de dialogue General sheet
  ///
  static void generalDialog(
    BuildContext context, {
    CustomModalSheetController? controller,
    AlignmentGeometry alignmentBox = Alignment.bottomCenter,
    bool displayTitle = true,
    Color? defaultCloseButtonColor,
    Color? backgroundColorTitleBox,
    double heightTitleBox = 40.0,
    EdgeInsets? paddingTitleBox =
        const EdgeInsets.only(left: 20.0, right: 20.0),
    String? title,
    TextStyle? titleStyle,
    List<Widget>? titleWidgetLeading,
    List<Widget>? titleWidgetTrailing,
    bool displayTrailingCloseButton = true,
    double widthXFactor = 0.85,
    double widthYFactor = 0.5,
    double? width,
    double? height,
    double? maxWidth,
    double? maxHeight,
    Color? backgroundColorModal,
    BorderRadius? borderRadiusModal,
    EdgeInsets? childPadding,
    bool isDismissible = true,
    double heightActionButtons = 40,
    List<Widget>? actionButtons,
    Widget? child,
  }) {
    // Etude de la position pour faire l'animation d'apparition
    Offset startAnim = const Offset(0, 1);
    Offset endAnim = const Offset(0, 0);
    if (alignmentBox == Alignment.topLeft ||
        alignmentBox == Alignment.topCenter ||
        alignmentBox == Alignment.topRight) {
      startAnim = const Offset(0, -1);
      endAnim = const Offset(0, 0);
    }

    // établissement des dimensions de la fenêtre
    double curWidth = width ?? MediaQuery.of(context).size.width * widthXFactor;
    if (maxWidth != null && maxWidth > 0) {
      curWidth = min(curWidth, maxWidth);
    }

    double curHeight =
        height ?? MediaQuery.of(context).size.height * widthYFactor;
    if (maxHeight != null && maxHeight > 0) {
      curHeight = min(curHeight, maxHeight);
    }

    // affichage de la fenêtre
    showGeneralDialog(
      barrierLabel: title ?? "",
      barrierDismissible: isDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        // design de la fenêtre
        Widget app = Align(
          alignment: alignmentBox,
          child: Container(
            width: curWidth,
            height: curHeight,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            decoration: BoxDecoration(
              color: backgroundColorModal ?? ToolsConfigApp.appWhiteColor,
              borderRadius: borderRadiusModal,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Access the width and height of the dialog window using constraints
                double dialogWidth = constraints.maxWidth;
                double dialogHeight = constraints.maxHeight;

                // retour du design
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: CustomModalGeneralDisplay(
                    controller: controller,
                    borderRadiusModal: borderRadiusModal,
                    displayTitle: displayTitle,
                    defaultCloseButtonColor: defaultCloseButtonColor,
                    backgroundColorTitleBox: backgroundColorTitleBox,
                    heightTitleBox: heightTitleBox,
                    paddingTitleBox: paddingTitleBox,
                    title: title,
                    titleStyle: titleStyle,
                    titleWidgetLeading: titleWidgetLeading,
                    titleWidgetTrailing: titleWidgetTrailing,
                    displayTrailingCloseButton: displayTrailingCloseButton,
                    childPadding: childPadding,
                    dialogWidth: dialogWidth,
                    dialogHeight: dialogHeight,
                    heightActionButtons: heightActionButtons,
                    actionButtons: actionButtons,
                    child: child ?? const Placeholder(),
                  ),
                );
              },
            ),
          ),
        );

        // affichage de la construction de la page
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Timer.periodic(const Duration(milliseconds: 500), (timer) {
            //   // Met à jour le contenu du dialogue
            //   setDialogState(() {});
            // });

            // affichage final de la boîte de dialogue
            return Material(
              color: Colors.transparent,
              child: app,
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: startAnim, end: endAnim).animate(anim1),
          child: child,
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
