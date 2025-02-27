///
/// Affichage du texte depuis un Markdown
///

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../../config/config.dart';
import '../../controllers/controllers.dart';

class CustomMarkdownText extends StatelessWidget {
  // constructeur
  const CustomMarkdownText({
    required this.text,
    this.factorSize = 1.0,
    this.scrollContentController,
    this.includeAutoSuffix = true,
    this.includeAutoMarkerSection = true,
    this.wrapAlignment = WrapAlignment.spaceEvenly,
    this.useAutoScrollText = true,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  /// Le texte
  ///
  final String text;

  /// facteur de grossissement du texte
  ///
  final double factorSize;

  /// inclut le suffixe prédéfini par l'utilisateur
  ///
  final bool includeAutoSuffix;

  /// ajout automatique d'une marque de changement de paragraphe
  ///
  final bool includeAutoMarkerSection;

  /// mode de justification du texte affiché
  ///
  final WrapAlignment wrapAlignment;

  /// indique si on utilise le widget [Markdown] avec gestion du scroll,
  /// sinon [MarkdownBody]
  ///
  final bool useAutoScrollText;

  /// The amount of space by which to inset the children.
  final EdgeInsets padding;

  /// An object that can be used to control the position to which this scroll view is scrolled.
  ///
  /// See also: [ScrollView.controller]
  final ScrollController? scrollContentController;

  @override
  Widget build(BuildContext context) {
    // initialisation du texte
    String textDisplay = text.trim().isNotEmpty ? text.trim() : "Aucun texte";
    if (includeAutoSuffix) {
      textDisplay = "$textDisplay\n\n";
    }
    if (includeAutoMarkerSection) {
      textDisplay = textDisplay.replaceAll("\n\n", "\n\n###### ※ ※ ※\n\n");
    }

    ///
    /// Fonction de traitement des liens du texte
    /// (pour rappel les liens : "[Mon site](https://www.pause-evasion.com)\n\n[Mon mail](mailto:toto@sample.com)\n\n[Mon tel](tel:+33102030405)")
    ///
    void onTapLink(String text, String? href, String? title) {
      if (href == null) {
        return;
      }
      // redirige vers l'URL
      ToolsConfigApp.logger.d("Markdown : redirection de '$text' vers $href");

      // lancement du navigateur
      final prefix = href.toLowerCase().trim();
      if (prefix.startsWith("http://") || prefix.startsWith("https://")) {
        ToolsHelpers.launchWeb(url: href);
      } else if (prefix.startsWith("mailto:")) {
        ToolsHelpers.launchEmail(email: href);
      } else if (prefix.startsWith("tel:")) {
        ToolsHelpers.launchPhoneNumber(phone: href);
      }
    }

    ///
    /// Style des éléments d'ecriture
    ///
    final styleSheet = MarkdownStyleSheet(
      // éléments d'écriture
      p: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(height: 1.7, fontSize: 24.0 * factorSize),
      h6: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(height: 1.7, fontSize: 16.0 * factorSize),
      h5: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(height: 1.7, fontSize: 20.0 * factorSize),
      h4: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(height: 1.7, fontSize: 24.0 * factorSize),
      h3: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(height: 1.7, fontSize: 26.0 * factorSize),
      h2: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(height: 1.7, fontSize: 28.0 * factorSize),
      h1: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(height: 1.7, fontSize: 30.0 * factorSize),

      // éléments de bloc
      codeblockPadding: EdgeInsets.zero,

      // table
      tableBorder:
          TableBorder.all(color: ToolsConfigApp.appPrimaryColor, width: 0),
      tableColumnWidth: const IntrinsicColumnWidth(),
      tableCellsPadding: const EdgeInsets.all(8.0),
      tableHeadAlign: TextAlign.start,

      // justification du texte
      textAlign: wrapAlignment,
    );

    ///
    /// Fabrication des extensions du markdown
    ///
    final Map<String, MarkdownElementBuilder> builders =
        <String, MarkdownElementBuilder>{
      // 'h2': CenteredHeaderBuilder(),
      'h6': CenteredHeaderBuilder(),
      // 'img': CenteredImageBuilder(),
    };

    ///
    /// Affichage du markdown
    ///
    if (useAutoScrollText) {
      return Markdown(
        controller: scrollContentController,
        data: textDisplay.trim(),

        // traitement des liens
        onTapLink: onTapLink,

        // style
        shrinkWrap: true,
        selectable: false,
        styleSheet: styleSheet,

        builders: builders,

        padding: padding,
      );
    } else {
      // construction du texte
      return Padding(
        padding: padding,
        child: MarkdownBody(
          data: textDisplay.trim(),

          // traitement des liens
          onTapLink: onTapLink,

          // style
          shrinkWrap: true,
          selectable: false,
          styleSheet: styleSheet,

          builders: builders,
        ),
      );
    }
  }
}

///
/// Widgets/élément pour le centrage d'élément dans le markdown
///
class CenteredHeaderBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text.text, style: preferredStyle),
      ],
    );
  }
}

class CenteredImageBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text.text, style: preferredStyle),
      ],
    );
  }
}
