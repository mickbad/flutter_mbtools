import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import "package:http/http.dart" as http;
import 'package:path/path.dart';
import 'package:slug_it/slug_it.dart';
import 'package:pasteboard/pasteboard.dart';

// ignore: must_be_immutable
class ImageFullScreenWrapperWidget extends StatelessWidget {
  bool isNetworkImage;
  final bool dark;
  final bool displayShareButton;
  final bool displaySaveButton;
  final bool displayClipboardButton;
  final bool closeOnTap;
  final bool shadow;
  final bool debugImageBorder;
  final String imageUrl;
  final String imageNameSaved;
  final AlignmentGeometry alignmentButtons;
  final String prefixImageName;
  final double? height;
  final double? width;

  ImageFullScreenWrapperWidget({
    super.key,
    required this.imageUrl,
    this.imageNameSaved = "shared",
    this.dark = true,
    this.closeOnTap = false,
    this.shadow = false,
    this.debugImageBorder = false,
    this.displayShareButton = false,
    this.displaySaveButton = false,
    this.displayClipboardButton = false,
    this.alignmentButtons = Alignment.bottomLeft,
    this.prefixImageName = "picture",
    this.width,
    this.height,
  }) : isNetworkImage = imageUrl.toLowerCase().startsWith("http://") ||
            imageUrl.toLowerCase().startsWith("https://");

  @override
  Widget build(BuildContext context) {
    // construction du shadow
    List<BoxShadow> boxShadow = [];
    if (shadow) {
      boxShadow = [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ];
    }

    // origine de l'image : réseau ou local
    ImageProvider image;
    if (isNetworkImage) {
      image = NetworkImage(imageUrl);
    } else {
      image = AssetImage(imageUrl);
    }

    // construction du widget d'affichage de l'image
    Widget fadeImage = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        border: (debugImageBorder) ? Border.all(color: Colors.red) : null,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: boxShadow,
      ),
      child: FadeInImage(
        placeholder: const AssetImage("assets/images/cupertino_loading.gif"),
        image: image,
        fit: BoxFit.contain,
        width: width,
        height: height,
      ),
    );

    // affichage du widget
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            barrierColor: dark ? Colors.black : Colors.white,
            pageBuilder: (BuildContext context, _, __) {
              return FullScreenPage(
                imageNameSaved: imageNameSaved,
                prefixImageName: prefixImageName,
                dark: dark,
                closeOnTap: closeOnTap,
                imageUrlShared: (isNetworkImage) ? imageUrl : null,
                displayShareButton: displayShareButton,
                displaySaveButton: displaySaveButton,
                displayClipboardButton: displayClipboardButton,
                alignmentButtons: alignmentButtons,
                child: fadeImage,
              );
            },
          ),
        );
      },

      // Affichage de l'image
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: fadeImage,
      ),
    );
  }
}

///
/// Enumérations pour l'exportation de l'image
///
enum ExportedImage {
  save,
  share,
  copy,
}

///
/// Affichage pleine écran
///
// ignore: must_be_immutable
class FullScreenPage extends StatefulWidget {
  FullScreenPage({
    super.key,
    required this.child,
    required this.dark,
    this.imageUrlShared,
    this.imageNameSaved = "shared",
    this.prefixImageName = "picture",
    this.closeOnTap = false,
    this.displayShareButton = false,
    this.displaySaveButton = false,
    this.displayClipboardButton = false,
    this.alignmentButtons = Alignment.bottomLeft,
  }) {
    // on détermine si on est sur une plateforme de type desktop
    if (kIsWeb) {
      isDesktopApplication = false;
      displayShareButton = false;
      displaySaveButton = false;
      displayClipboardButton = false;
    } else {
      isDesktopApplication =
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

      // Annulation de l'option partage sur certaines plateforme
      if (Platform.isLinux) {
        displayShareButton = false;
      }
      if (Platform.isWindows || Platform.isAndroid) {
        displayClipboardButton = false;
      }
    }

    // attribution d'un nom à l'image téléchargée pour une sauvegarde ou un partage
    if (imageNameSaved.isEmpty) {
      imageNameSaved = "shared";
    }

    // slugification du nom de l'image
    imageNameSaved = SlugIT().makeSlug(imageNameSaved);
  }

  final Widget child;
  final bool dark;
  bool displayShareButton;
  bool displaySaveButton;
  bool displayClipboardButton;
  final bool closeOnTap;
  final String? imageUrlShared;
  String imageNameSaved;
  final String prefixImageName;
  final AlignmentGeometry alignmentButtons;
  bool isDesktopApplication = false;

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  // Resource Internet sur l'image téléchargé
  http.Response? responseInternetImage;

  // chemin du stockage du fichier temporaire
  String imageDownloadedPathTemp = "";
  String imageDownloadedPathName = "";

  @override
  void initState() {
    var brightness = widget.dark ? Brightness.light : Brightness.dark;
    var color = widget.dark ? Colors.black12 : Colors.white70;

    // Récupération de la ressource internet
    if (widget.imageUrlShared != null) {
      final url = Uri.parse(widget.imageUrlShared!);
      http.get(url).then((value) {
        if (mounted) {
          setState(() => responseInternetImage = value);
        }
      });
    }

    // construction du lieu de stockage du fichier à télécharger pour le partage
    getTemporaryDirectory()
        .then((tempDir) => imageDownloadedPathTemp = tempDir.path);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: color,
      statusBarColor: color,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarDividerColor: color,
      systemNavigationBarIconBrightness: brightness,
    ));
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        // Restore your settings here...
        ));

    // suppression du fichier temporaire s'il existe
    if (imageDownloadedPathName.isNotEmpty &&
        File(imageDownloadedPathName).existsSync()) {
      File(imageDownloadedPathName).delete();
    }

    // Destruction du widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.dark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 333),
                curve: Curves.fastOutSlowIn,
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child: GestureDetector(
                    onTap: () => (widget.closeOnTap)
                        ? Navigator.of(context).pop()
                        : null,
                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: widget.alignmentButtons,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // bouton de retour
                    buildToolsButton(
                      icon: Icons.arrow_back,
                      tooltip: "Return",
                      action: () => Navigator.of(context).pop(),
                    ),

                    // outils de visionnage
                    if (responseInternetImage != null)
                      Row(
                        children: [
                          // bouton de copie de l'image
                          if (widget.displayClipboardButton)
                            buildToolsButton(
                              icon: Icons.copy,
                              tooltip: "Copy to clipboard",
                              action: () => exportContent(context,
                                  mode: ExportedImage.copy),
                            ),

                          if (widget.displayClipboardButton)
                            const SizedBox(width: 10),

                          // bouton de sauvegarde
                          if (widget.displaySaveButton)
                            buildToolsButton(
                              icon: Icons.save_alt,
                              tooltip: "Save",
                              action: () => exportContent(context,
                                  mode: ExportedImage.save),
                            ),

                          if (widget.displayShareButton)
                            const SizedBox(width: 10),

                          // Bouton de partage
                          if (widget.displayShareButton)
                            buildToolsButton(
                              icon: Icons.share,
                              tooltip: "Share",
                              action: () => exportContent(context,
                                  mode: ExportedImage.share),
                            ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  /// Construction du bouton d'outil
  ///
  Widget buildToolsButton(
      {required IconData icon,
      VoidCallback? action,
      double iconSize = 25,
      String? tooltip}) {
    return Tooltip(
      message: tooltip ?? "",
      child: MaterialButton(
        padding: const EdgeInsets.all(15),
        elevation: 0,
        color: widget.dark ? Colors.black38 : Colors.white70,
        highlightElevation: 0,
        minWidth: double.minPositive,
        height: double.minPositive,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        onPressed: action,
        child: Icon(
          icon,
          color: widget.dark ? Colors.white : Colors.black,
          size: iconSize,
        ),
      ),
    );
  }

  ///
  /// Partage de contenu dans l'application
  ///
  Future exportContent(BuildContext context,
      {required ExportedImage mode}) async {
    if (widget.imageUrlShared == null) {
      return;
    }

    // Message utilisateur de réussite
    String message = "";
    Color snackbarTextColor = Colors.red;

    try {
      // Récupération de la ressource internet
      if (responseInternetImage == null) {
        throw Exception("Image not available yet.");
      }

      // Traitement de la reponse
      if (responseInternetImage!.statusCode != 200) {
        throw Exception("Image not found.");
      }

      // Récupération du fichier
      bool isFilepathSet = false;
      // String fileExtension = "";
      List<String>? allowedExtensions;
      if (responseInternetImage!.headers.containsKey('content-type')) {
        if (responseInternetImage!.headers['content-type']!.contains('png')) {
          isFilepathSet = true;
          allowedExtensions = [
            "png",
          ];
          // fileExtension = "png";
          imageDownloadedPathName =
              '$imageDownloadedPathTemp/${widget.prefixImageName}-${widget.imageNameSaved}.png';
        }

        if (responseInternetImage!.headers['content-type']!.contains('jpg') ||
            responseInternetImage!.headers['content-type']!.contains('jpeg')) {
          isFilepathSet = true;
          allowedExtensions = ["jpg", "jpeg"];
          // fileExtension = "jpg";
          imageDownloadedPathName =
              '$imageDownloadedPathTemp/${widget.prefixImageName}-${widget.imageNameSaved}.jpg';
        }
      }

      // condition de sortie
      if (!isFilepathSet) {
        throw Exception("Resource is not kwown image.");
      }

      ///
      /// Interpréation du mode de partage
      ///
      // message d'annulation
      message = "Exportation mode missing!";
      switch (mode) {
        case ExportedImage.share:
          // Partage du fichier
          // message d'annulation
          message = "Sharing ${basename(imageDownloadedPathName)} canceled.";

          // Ecriture du fichier pour le partage dans la zone temporaire
          await File(imageDownloadedPathName)
              .writeAsBytes(responseInternetImage!.bodyBytes);

          // partage utilisateur
          final result = await Share.shareXFiles(
              [XFile(imageDownloadedPathName)],
              text: 'CheckingURL');
          if (result.status == ShareResultStatus.success) {
            message =
                "Sharing ${basename(imageDownloadedPathName)} successful.";
            snackbarTextColor = widget.dark ? Colors.white : Colors.black;
          }
          break;

        case ExportedImage.save:
          // Sauvegarde du fichier
          // message d'annulation
          message = "Saving ${basename(imageDownloadedPathName)} canceled.";

          // demande de sauvegarde du fichier
          String? outputFile;
          if (widget.isDesktopApplication) {
            // localisation du fichier sur le desktop
            outputFile = await FilePicker.platform.saveFile(
              dialogTitle: 'Please select an output file:',
              fileName: basename(imageDownloadedPathName),
              allowedExtensions: allowedExtensions,
            );
          } else {
            // localisation du fichier sur le mobile
            final paramsSaveMobileFile = SaveFileDialogParams(
              data: responseInternetImage!.bodyBytes,
              fileName: basename(imageDownloadedPathName),
            );
            outputFile =
                await FlutterFileDialog.saveFile(params: paramsSaveMobileFile);
          }

          // vérification du travail de sauvegarde
          if (outputFile != null) {
            // détection si l'extension est correct
            // if (!outputFile.endsWith(".$fileExtension")) {
            //   outputFile = outputFile + ".$fileExtension";
            // }

            // stockage du fichier en mode desktop
            if (widget.isDesktopApplication) {
              await File(outputFile)
                  .writeAsBytes(responseInternetImage!.bodyBytes);
            }

            // message de validation
            message = "Saving ${basename(outputFile)} successful.";
            snackbarTextColor = widget.dark ? Colors.white : Colors.black;
          }
          break;

        case ExportedImage.copy:
          // Copie du fichier dans le clipboard
          // message d'annulation
          message = "Copying ${basename(imageDownloadedPathName)} canceled.";

          // copie dans le clipboard pour ios, macos, ...?
          bool success = true;
          if (Platform.isIOS || Platform.isMacOS) {
            await Pasteboard.writeImage(responseInternetImage!.bodyBytes);
          } else {
            // Ecriture du fichier pour le partage dans la zone temporaire
            await File(imageDownloadedPathName)
                .writeAsBytes(responseInternetImage!.bodyBytes);
            final paths = [imageDownloadedPathName];
            success = await Pasteboard.writeFiles(paths);
          }

          if (success) {
            message =
                "Copying ${basename(imageDownloadedPathName)} successful.";
            snackbarTextColor = widget.dark ? Colors.white : Colors.black;
          }
          break;
      } // fin switch : mode d'exportation
    } catch (e) {
      // erreur trouvée
      message = e.toString();
    } finally {
      // affichage du message
      if (message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            // behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Close',
              textColor: snackbarTextColor,
              onPressed: () {
                //Navigator.pop(context);
              },
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // margin: EdgeInsets.only(
            //   bottom: MediaQuery.of(context).size.height - 100,
            //   right: 20,
            //   left: 20
            // ),
          ),
        );
      }
    }
  }
}
