///
/// Gestion d'un menu globale avec fond d'écran
///

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../config/config.dart';
import '../views.dart';

// ignore: must_be_immutable
class ExtendedContainerContent extends StatefulWidget {
  ExtendedContainerContent({
    super.key,
    this.displayAds = false,
    this.onInlineMenusAddonWidgetRandom,
    this.padding = 8.0,
    required this.width,
    required this.height,
    required this.imageAsset,
    this.imageType = BackgroundImageType.asset,
    this.background = Colors.black,
    this.imageGyroscopeAnimate = false,
    this.imageAnimate = true,
    this.imageZoomFirst = 1.0,
    this.imageZoomLast = 1.10,
    this.title,
    this.titleStyle,
    this.titleStyleStrokeWidth = 3.0,
    this.subtitle,
    this.subtitleStyle,
    this.subtitleStyleStrokeWidth = 3.0,
    this.legend,
    this.topActions,
    this.bottomActions,
    this.onReturnTap,
    this.menus,
    this.menusController,
    this.menusDisplayScrollButtons = false,
    this.menusScrollOffsetVertical = 10.0,
    this.menusDisplayScrollButtonsLeftPosition,
    this.menusDisplayScrollButtonsRightPosition,
    this.controllerOpenLink,
    this.contentChild,
    this.contentWidth,
    this.contentHeight,
    this.contentBorderColor = Colors.white,
    this.contentBackgroundColor,
    this.contentBackgroundStartGradientColor,
    this.contentBackgroundEndGradientColor,
    this.childOverlayColor,
    this.child,
  }) : assert(contentChild == null || menus == null) {
    // création d'un controleur de scroll des menus en automatique si demandé
    if (menusDisplayScrollButtons || menusController == null) {
      menusController = ScrollController();
    }

    // gestion de l'offset du scroll menu
    menusScrollOffsetVertical = max(1.0, menusScrollOffsetVertical);

    // gestion du positionnement des boutons de scroll
    if (menusDisplayScrollButtonsLeftPosition == null &&
        menusDisplayScrollButtonsRightPosition == null) {
      // on force l'utilisation des boutons scroll à droite
      menusDisplayScrollButtonsRightPosition = 10;
    }
  }

  final bool displayAds;

  final double width;
  final double height;
  final double padding;

  final Widget? contentChild;
  final double? contentWidth;
  final double? contentHeight;
  final Color contentBorderColor;
  final Color? contentBackgroundColor;
  final Color? contentBackgroundStartGradientColor;
  final Color? contentBackgroundEndGradientColor;

  final Color background;

  final bool imageAnimate;
  final bool imageGyroscopeAnimate;
  final String imageAsset;
  final BackgroundImageType imageType;
  final double imageZoomFirst;
  final double imageZoomLast;

  final String? title;
  final TextStyle? titleStyle;
  final double titleStyleStrokeWidth;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final double subtitleStyleStrokeWidth;
  final String? legend;

  final List<Widget>?
      topActions; // Liste des actions disponibles dans la fenêtre en haut à droite
  final List<Widget>?
      bottomActions; // Liste des actions disponibles dans la fenêtre en bas à gauche

  final VoidCallback? onReturnTap;

  final BackgroundOpenLinkController? controllerOpenLink;

  // gestion des menus internes
  final List<MenuButtonItem>? menus;

  // controleur externe du scroll pour l'affichage des menus (gestion des positions)
  ScrollController? menusController;

  // affichage des flêches de direction du scroll du contenu des menus
  final bool menusDisplayScrollButtons;

  // offset de scroll des menus si [menusDisplayScrollButtons] est vrai
  double menusScrollOffsetVertical;

  // positionnement des flêches de direction du scroll
  double? menusDisplayScrollButtonsLeftPosition;
  double? menusDisplayScrollButtonsRightPosition;

  // Contenu de surcouche au background (taille du container)
  final Color? childOverlayColor;
  final Widget? child;

  // contenu additionnel entre chaque menu (type banière de publicité)
  final Widget Function()? onInlineMenusAddonWidgetRandom;

  @override
  State<ExtendedContainerContent> createState() =>
      _ExtendedContainerContentState();
}

class _ExtendedContainerContentState extends State<ExtendedContainerContent> {
  // encadrement de la zone de titre/en-tête du contenu
  final GlobalKey _headerWidgetKey = GlobalKey();

  // gestion de la présence d'un scroll dans le système de menu
  final GlobalKey _columnMenuKey = GlobalKey();
  bool _needsMenuScroll = false;

  @override
  void initState() {
    super.initState();

    // on surveille le scroll des menus
    widget.menusController?.addListener(_scrollMenuListener);

    // après la première frame, on calcule
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // doit-on afficher le bouton scroll en fin de menu ?
      _checkIfNeedsMenuScroll();
    });
  }

  @override
  void dispose() {
    widget.menusController?.removeListener(_scrollMenuListener);
    widget.menusController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // gestion du gradient glass
    LinearGradient? gradient;
    if (widget.contentBackgroundStartGradientColor != null ||
        widget.contentBackgroundEndGradientColor != null) {
      gradient = LinearGradient(
        colors: [
          widget.contentBackgroundStartGradientColor ??
              Colors.white.withValues(alpha: 0.0),
          widget.contentBackgroundEndGradientColor ??
              Colors.white.withValues(alpha: 0.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    // insertion des annonces dans les menus si disponible
    List<Widget>? inlineMenus;
    if (widget.menus != null && widget.menus!.isNotEmpty) {
      inlineMenus = [
        ...?widget.menus,

        // espace vide de fin de page
        MenuButtonItem.empty(emptyButtonHeight: 20.0),
      ];

      // insertion de bannières
      if (widget.displayAds && widget.onInlineMenusAddonWidgetRandom != null) {
        // au mileu
        for (int i = 0; i < inlineMenus.length - 1; i++) {
          if (i > 0 && i % 4 == 0) {
            inlineMenus.insert(i, widget.onInlineMenusAddonWidgetRandom!());
          }
        }

        // vers la fin
        if (inlineMenus.length > 3 &&
            inlineMenus[inlineMenus.length - 3].runtimeType == MenuButtonItem) {
          inlineMenus.insert(
              inlineMenus.length - 2, widget.onInlineMenusAddonWidgetRandom!());
        }

        // au début
        inlineMenus.insert(1, widget.onInlineMenusAddonWidgetRandom!());
      }
    }

    // gestion de l'enfant si actif
    Widget childContent = Container();
    if (widget.contentChild != null || widget.menus != null) {
      childContent = Center(
        child: GlassContainer(
          height: min(widget.height,
              max(0, widget.contentHeight ?? widget.height * .9)),
          width: min(
              widget.width, max(0, widget.contentWidth ?? widget.width * .6)),
          blur: 10,
          // color: Colors.white.withValues(alpha: 0.1),
          color: widget.contentBackgroundColor ??
              Colors.white.withValues(alpha: 0.1),

          // rond central pour le flare?
          gradient: gradient,

          // le border
          border: Border.fromBorderSide(
              BorderSide(width: 1.0, color: widget.contentBorderColor)),
          borderRadius: BorderRadius.circular(16),

          // l'ombre
          shadowStrength: 10,
          shadowColor: Colors.white.withValues(alpha: 0.24),

          // contenu
          child: Padding(
            padding: EdgeInsets.all(widget.padding),
            child: Stack(
              children: [
                // affichage d'une légende
                if (widget.legend != null) ...[
                  // copyright
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      widget.legend!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 12),
                    ),
                  ),
                ],

                // contenu réel
                Column(
                  children: [
                    Row(
                      key: _headerWidgetKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              // titre de la page
                              if (widget.title != null &&
                                  widget.title!.trim().isNotEmpty) ...[
                                // Titre
                                Center(
                                  child: StrokeText(
                                    widget.title!,
                                    style: widget.titleStyle ??
                                        Theme.of(context).textTheme.titleLarge,
                                    strokeWidth: widget.titleStyleStrokeWidth,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],

                              // sous titre de la page
                              if (widget.subtitle != null &&
                                  widget.subtitle!.trim().isNotEmpty) ...[
                                // Titre
                                Center(
                                  child: StrokeText(
                                    widget.subtitle!,
                                    style: widget.subtitleStyle ??
                                        Theme.of(context).textTheme.titleSmall,
                                    strokeWidth:
                                        widget.subtitleStyleStrokeWidth,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // actions en haut à droite
                        if (widget.topActions != null &&
                            widget.topActions!.isNotEmpty) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: widget.topActions!,
                          ),
                        ],
                      ],
                    ),

                    // affichage des menus
                    if (inlineMenus != null) ...[
                      Expanded(
                        child: Column(
                          children: [
                            // affichage des menus
                            Expanded(
                              child: SingleChildScrollView(
                                controller: widget.menusController,
                                child: Column(
                                  key: _columnMenuKey,
                                  children: inlineMenus,
                                ),
                              ),
                            ),

                            if (_needsMenuScroll) ...[
                              // affichage d'une icône qui indique s'il y a du contenu en suivant
                              Center(
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: ToolsConfigApp.appPrimaryColor,
                                  size: 30,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    ],

                    // affichage du contenu supplémentaire
                    if (widget.contentChild != null)
                      Expanded(child: widget.contentChild!),
                    // if (menus != null) ...menus!,
                    // if (child != null) ...[child!],
                  ],
                ),

                // retour page précédente
                if (widget.onReturnTap != null) ...[
                  // bouton de retour
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: widget.onReturnTap,
                      icon: Icon(
                        Icons.arrow_back,
                        color: ToolsConfigApp.appInvertedColor,
                      ),
                    ),
                  ),
                ],

                // // actions en haut à droite
                // if (topActions != null && topActions!.isNotEmpty) ... [
                //   Align(
                //     alignment: Alignment.topRight,
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: topActions!,
                //     ),
                //   ),
                // ],
                //
                // actions en bas à gauche
                if (widget.bottomActions != null &&
                    widget.bottomActions!.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.bottomActions!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // affichage
    return BackgroundImageAnimated(
      animate: widget.imageAnimate,
      useGyroscopeMotion: widget.imageGyroscopeAnimate,
      width: widget.width,
      height: widget.height,
      background: widget.background,
      image: widget.imageAsset,
      imageType: widget.imageType,
      imageZoomFirst: widget.imageZoomFirst,
      imageZoomLast: widget.imageZoomLast,
      controllerOpenLink: widget.controllerOpenLink,

      // menu
      child: Stack(
        children: [
          // contenu externe
          Container(
            width: widget.width,
            height: widget.height,
            color: widget.childOverlayColor,
            child: widget.child,
          ),

          // contenu interne avec encadré
          childContent,

          // système de navigation du scroll du contenu en automatique si demandé
          if (widget.menusDisplayScrollButtons &&
              widget.menusController != null) ...[
            // flêche de guidage
            Positioned(
              left: widget.menusDisplayScrollButtonsLeftPosition,
              right: widget.menusDisplayScrollButtonsRightPosition,
              top: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onLongPress: () {
                    widget.menusController!.animateTo(
                      0.0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.bounceOut,
                    );
                  },
                  onDoubleTap: () {
                    final position = widget.menusController!.offset;
                    widget.menusController!.animateTo(
                      max(position - widget.menusScrollOffsetVertical * 2, 0.0),
                      duration: const Duration(seconds: 1),
                      curve: Curves.bounceOut,
                    );
                  },
                  onTap: () {
                    final position = widget.menusController!.offset;
                    widget.menusController!.animateTo(
                      max(position - widget.menusScrollOffsetVertical, 0.0),
                      duration: const Duration(seconds: 1),
                      curve: Curves.bounceOut,
                    );
                  },
                  child: Icon(
                    Icons.arrow_upward,
                    color: ToolsConfigApp.appPrimaryColor,
                  ),
                ),
              ),
            ),

            Positioned(
              left: widget.menusDisplayScrollButtonsLeftPosition,
              right: widget.menusDisplayScrollButtonsRightPosition,
              bottom: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onLongPress: () {
                    widget.menusController!.animateTo(
                      widget.menusController!.position.maxScrollExtent,
                      duration: const Duration(seconds: 1),
                      curve: Curves.bounceOut,
                    );
                  },
                  onDoubleTap: () {
                    final position = widget.menusController!.offset;
                    widget.menusController!.animateTo(
                      min(position + widget.menusScrollOffsetVertical * 2,
                          widget.menusController!.position.maxScrollExtent),
                      duration: const Duration(seconds: 1),
                      curve: Curves.bounceOut,
                    );
                  },
                  onTap: () {
                    final position = widget.menusController!.offset;
                    widget.menusController!.animateTo(
                      min(position + widget.menusScrollOffsetVertical,
                          widget.menusController!.position.maxScrollExtent),
                      duration: const Duration(seconds: 1),
                      curve: Curves.bounceOut,
                    );
                  },
                  child: Icon(
                    Icons.arrow_downward,
                    color: ToolsConfigApp.appPrimaryColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  ///
  /// Vérification si l'affichage des menus demande un scroll
  ///
  void _checkIfNeedsMenuScroll() {
    // vérification
    if (_columnMenuKey.currentContext == null) {
      return;
    }

    // zone des menus
    final RenderBox renderBox =
        _columnMenuKey.currentContext!.findRenderObject() as RenderBox;
    final columnHeight = renderBox.size.height;

    // zone de la fenêtre affichant (sans l'entête)
    final RenderBox renderBoxHeader =
        _headerWidgetKey.currentContext!.findRenderObject() as RenderBox;
    final screenHeight = MediaQuery.of(context).size.height -
        renderBoxHeader.size.height -
        widget.padding;

    // mise à jour de l'affichage du bouton scroll
    setState(() {
      _needsMenuScroll = columnHeight > screenHeight;
    });
  }

  ///
  /// Surveillance du scroll des menus
  ///
  void _scrollMenuListener() {
    final scrollController = widget.menusController!;
    setState(() {
      _needsMenuScroll = (scrollController.position.pixels <
          scrollController.position.maxScrollExtent);
    });
  }
}

///
/// Objet de construction automatique d'un menu avec Image
///
class MenuButtonItem extends StatelessWidget {
  const MenuButtonItem({
    super.key,
    this.color,
    this.imageAsset,
    this.imageFile,
    this.imageColorBend,
    this.imageColorBlendMode = BlendMode.softLight,
    required this.heightMenus,
    this.borderRadius = 5.0,
    this.padding = const EdgeInsets.all(5.0),
    this.margin = const EdgeInsets.only(top: 10.0, bottom: 5.0),
    this.onTap,
    this.trailing,
    this.leading,
    this.title,
    this.titleStyle,
    this.titleStrokeWidth = 2.0,
    this.children,
    this.enabled = true,
    this.emptyButtonHeight = 0.0,
    this.actionsStart,
    this.actionsEnd,
  }) : assert(imageAsset == null || imageFile == null);

  factory MenuButtonItem.empty({required double emptyButtonHeight}) {
    return MenuButtonItem(
      heightMenus: 0.0,
      emptyButtonHeight: emptyButtonHeight,
      imageAsset: '',
    );
  }

  final double heightMenus;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final String? imageAsset;
  final String? imageFile;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? leading;
  final String? title;
  final TextStyle? titleStyle;
  final double titleStrokeWidth;
  final List<Widget>? children;

  // options
  final bool enabled;
  final double emptyButtonHeight;
  final Color? imageColorBend;
  final BlendMode imageColorBlendMode;

  // options autour du bouton pour les actions tierces
  final List<Widget>? actionsEnd;
  final List<Widget>? actionsStart;

  // image d'arrière plan
  ImageProvider? get imageAssetOrFile {
    if (imageAsset != null) {
      // détection d'une url
      if (imageAsset!.toLowerCase().startsWith('http://') ||
          imageAsset!.toLowerCase().startsWith('https://')) {
        return NetworkImage(imageAsset!);
      }
      return AssetImage(imageAsset!);
    }
    if (imageFile != null) {
      return FileImage(File(imageFile!));
    }
    if (color != null) {
      return null;
    }

    // erreur
    throw Exception('imageAsset or imageFile or color must not be null');
  }

  @override
  Widget build(BuildContext context) {
    // affichage d'un espace unique si demandée
    if (emptyButtonHeight > 0.0) {
      return SizedBox(
        height: emptyButtonHeight,
      );
    }

    // affichage du bouton
    Widget child = RippleImageButton(
      image: imageAssetOrFile,
      color: color,
      height: heightMenus,
      onTap: (enabled) ? onTap : null,
      borderRadius: borderRadius,
      borderColor:
          Theme.of(context).secondaryHeaderColor.withValues(alpha: 0.5),
      splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      overlayColor: (enabled) ? null : Colors.black.withValues(alpha: 0.4),
      imageColorFilterEnabled: (imageColorBend != null),
      imageColorFilter:
          ColorFilter.mode(imageColorBend ?? Colors.black, imageColorBlendMode),
      padding: padding,
      margin: margin,
      trailing: trailing,
      leading: leading,
      childrenCrossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // titre du menu
        if (title != null)
          StrokeText(
            title!,
            style: titleStyle ?? Theme.of(context).textTheme.titleSmall,
            strokeWidth: titleStrokeWidth,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

        // contenu du menu
        if (children != null) ...children!,
      ],
    );

    // dismissed
    if ((actionsEnd != null && actionsEnd!.isNotEmpty) ||
        (actionsStart != null && actionsStart!.isNotEmpty)) {
      child = Slidable(
        // Specify a key if the Slidable is dismissible.
        key: UniqueKey(),

        // The end action pane is the one at the right or the bottom side.
        endActionPane: (actionsEnd == null || actionsEnd!.isEmpty)
            ? null
            : ActionPane(
                motion: const ScrollMotion(),
                children: actionsEnd ?? [],
              ),

        // The start action pane is the one at the left or the top side.
        startActionPane: (actionsStart == null || actionsStart!.isEmpty)
            ? null
            : ActionPane(
                motion: const ScrollMotion(),
                children: actionsStart!,
              ),

        // The child of the Slidable is what the user sees when the
        // component is not dragged.
        child: child,
      );
    }

    // retour
    return child;
  }
}
