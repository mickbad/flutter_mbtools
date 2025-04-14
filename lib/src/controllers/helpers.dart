///
/// Fonctions utilitaires
///

import 'dart:io';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mbtools/mbtools.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:path/path.dart' as p;
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
// import 'package:html/parser.dart' as html_parser;
// import 'package:html/dom.dart' as html_dom;

///
/// Outils helpers
///
class ToolsHelpers {
  ///
  /// Tools : get real pathname
  ///
  static Future<String> realAppDocumentsPathname(String pathname) async {
    // get documents path
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();

    // construct pathname
    return p.join(
      appDocumentsDir.path,
      pathname,
    );
  }

  static Future<String> realAppSupportPathname(String pathname) async {
    // sortie si web
    if (kIsWeb) {
      return p.join(
        ".",
        pathname,
      );
    }

    // get support path
    final Directory appDocumentsDir = await getApplicationSupportDirectory();

    // construct pathname
    String myPath = p.join(
      appDocumentsDir.path,
      pathname,
    );

    // changement d'orientation des slashs si windows !
    if (Platform.isWindows) {
      myPath = myPath.replaceAll("/", "\\");
    }
    return myPath;
  }

  // ---------------------------------------------------------------------------
  // - Gestion des devices
  // ---------------------------------------------------------------------------

  ///
  /// Récupération du numéro unique de l'utilisateur de l'application sur son
  /// device actuel
  ///
  static Future<String?> getUniqueDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? identifier;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        identifier = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        identifier = iosInfo.identifierForVendor;
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        identifier = linuxInfo.machineId;
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macOsInfo = await deviceInfo.macOsInfo;
        identifier = macOsInfo.systemGUID;
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        identifier = windowsInfo.deviceId;
      } else if (kIsWeb) {
        WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        identifier = webInfo.vendor! +
            webInfo.userAgent! +
            webInfo.hardwareConcurrency.toString();
      }
    } catch (e) {
      return null;
    }

    return identifier;
  }

  ///
  /// Récupération des informations de l'appareil IOS
  ///
  static Future<(String, String)> getLocalIOSDeviceInfo() async {
    if (!Platform.isIOS) {
      return ("", "");
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo info = await deviceInfo.iosInfo;
    return (info.model, info.systemVersion);
  }

  ///
  /// Est-ce un iphone ?
  ///
  static Future<bool> isIphone() async {
    // récupération des informations du device
    String model;
    (model, _) = await getLocalIOSDeviceInfo();
    if (model.isEmpty) {
      return false;
    }
    return model.toLowerCase().contains("iphone");
  }

  ///
  /// Est-ce un ipad ?
  ///
  static Future<bool> isIpad() async {
    // récupération des informations du device
    String model;
    (model, _) = await getLocalIOSDeviceInfo();
    if (model.isEmpty) {
      return false;
    }
    return model.toLowerCase().contains("ipad");
  }

  ///
  /// Détermine si le device a un notch
  ///
  static bool hasNotch(BuildContext context) {
    final padding = MediaQuery.of(context).viewPadding;
    return padding.top != 0.0 ||
        padding.bottom != 0.0 ||
        padding.left != 0.0 ||
        padding.right != 0.0;
  }

  // ---------------------------------------------------------------------------
  // - Gestion des URLs
  // ---------------------------------------------------------------------------

  ///
  /// Validation d'une url
  ///
  static bool validateHttpUrl(String url) {
    // Expression régulière pour correspondre à une URL http ou https complète
    final RegExp regex = RegExp(
      r'^https?://[^\s/$.?#].\S*$',
      caseSensitive: false,
    );

    // Vérifie si l'URL correspond au format requis
    return regex.hasMatch(url);
  }

  ///
  /// Procédure de téléchargement d'une ressouce sur internet et sauvegarde dans
  /// un fichier en local
  /// [encrypt] : vrai pour que le fichier soit crypté après la lecture
  ///
  static Future<String?> downloadUrlToFile(
    String url,
    String pathname, {
    bool encrypt = false,
    String? encryptAESKey,
  }) async {
    try {
      // Envoyer une requête GET à l'URL
      final response = await http.get(Uri.parse(url));

      // Créer le fichier
      final file = File(pathname);

      // lecture des données
      Uint8List body = response.bodyBytes;

      // chiffrement?
      if (encrypt) {
        body = encryptAESBytes(body, encryptAESKey);
      }

      // Écrire les données de la réponse dans le fichier
      await file.writeAsBytes(body, flush: true);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  ///
  /// Appel d'un contact par téléphone
  ///
  static Future<void> launchPhoneNumber({required String phone}) async {
    // check du téléphone
    if (!phone.toLowerCase().startsWith("tel:")) {
      // ajout du module de téléphone
      phone = "tel:$phone";
    }

    if (await canLaunchUrlString(phone)) {
      await launchUrlString(phone);
    }
  }

  ///
  /// Envoi d'un email à un contact
  ///
  static Future<void> launchEmail({required String email}) async {
    // check de l'email
    if (!email.toLowerCase().startsWith("mailto:")) {
      // ajout du module de téléphone
      email = "mailto:$email";
    }

    if (await canLaunchUrlString(email)) {
      await launchUrlString(email);
    }
  }

  ///
  /// Ouverture d'une page web interne
  ///
  static Future<void> launchWeb({required String url}) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  // ---------------------------------------------------------------------------
  // - Gestion des chiffrements
  // ---------------------------------------------------------------------------

  ///
  /// Outil pour créer un mot de passe aléatoire
  ///
  static String generatePassword({
    required int length,
    bool enableNumber = true,
    bool enableLetters = true,
    bool enableSpecial = false,
    bool lowerCase = false,
    bool upperCase = false,
    bool removeAmbigousItems = false,
  }) {
    // dictionnary
    const String numbers = '0123456789';
    const String letters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String special = ':,-/@*+=_()[]{}&\$';
    const String ambigousItems = '10oOlL';

    // construction du dictionnaire autorisé
    String dictionnary = '';
    if (enableNumber) dictionnary += numbers;
    if (enableLetters) dictionnary += letters;
    if (enableSpecial) dictionnary += special;

    // suppression des entités ambigue pour l'utilisateur (L, l, 1, o, O ...)
    if (removeAmbigousItems) {
      dictionnary = dictionnary
          .split('')
          .where((c) => !ambigousItems.contains(c))
          .join('');
    }

    // test d'arguments
    if (dictionnary.isEmpty) {
      throw ArgumentError('must enable [number] or [letters] or [special]!');
    }

    // retour du mot de passe
    final random = Random();
    String password = List.generate(
            length, (index) => dictionnary[random.nextInt(dictionnary.length)])
        .join('');

    // dernière opération
    if (lowerCase) password = password.toLowerCase();
    if (upperCase) password = password.toUpperCase();
    return password;
  }

  ///
  /// Outil pour chiffrer une chaine de bytes
  ///
  static Uint8List encryptAESBytes(Uint8List body, [String? encryptAESKey]) {
    // récupération de la clef automatique si besoin
    encryptAESKey ??= ToolsConfigApp.preferences.getCurrentUserSecretKey();
    if (encryptAESKey.length != 32) {
      throw ArgumentError("must set a 32-length password");
    }

    // configuration
    final key = encrypt.Key.fromUtf8(encryptAESKey);
    final iv = encrypt.IV.allZerosOfLength(16);

    // chiffrement
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encryptBytes(body, iv: iv);

    return encrypted.bytes;
  }

  ///
  /// Outil pour déchiffrer une chaine de bytes
  ///
  static Uint8List decryptAESBytes(Uint8List body, [String? encryptAESKey]) {
    // récupération de la clef automatique si besoin
    encryptAESKey ??= ToolsConfigApp.preferences.getCurrentUserSecretKey();
    if (encryptAESKey.length != 32) {
      throw ArgumentError("must set a 32-length password");
    }

    // configuration
    final key = encrypt.Key.fromUtf8(encryptAESKey);
    final iv = encrypt.IV.allZerosOfLength(16);

    try {
      // déchiffrement
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter.decryptBytes(encrypt.Encrypted(body), iv: iv);

      return Uint8List.fromList(decrypted);
    } catch (e) {
      // erreur de déchiffrement !
      return Uint8List.fromList(body);
      // return Uint8List.fromList("".codeUnits);
    }
  }

  // ---------------------------------------------------------------------------
  // - Gestion des textes
  // ---------------------------------------------------------------------------

  ///
  /// Convertion d'un texte HTML en texte brut
  ///
  static String htmlToText(String html) {
    // Remplacement des balises de saut de ligne par des retours explicites
    html = html.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    html = html.replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n');

    // Expression régulière pour supprimer toutes les autres balises HTML
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);

    // Remplacement des balises restantes par une chaîne vide
    final brut = html.replaceAll(regex, '');

    // Nettoyage des espaces en trop
    return brut.trim();
  }

  ///
  /// Outil pour ne garder que les caractères alphanumériques dans un texte
  ///
  static String textOnlyAlphanumeric(
    String text, {
    bool keepSpace = true,
    bool lowercase = false,
    bool uppercase = false,
  }) {
    // Expression régulière pour ne garder que les caractères alphanumériques et les espaces
    String regexString = (keepSpace) ? r'[^a-zA-Z0-9\s]' : r'[^a-zA-Z0-9]';

    // transformation du texte
    text = text.replaceAll(RegExp(regexString), '');

    // casse du texte
    if (lowercase) {
      text = text.toLowerCase();
    }
    if (uppercase) {
      text = text.toUpperCase();
    }

    return text;
  }

  ///
  /// Outil de suppression de contenu en en-tête d'une phrase
  /// [text] : texte à nettoyer
  /// [removeText] : texte à supprimer en en-tête
  ///
  static String textRemovePrefix(String text,
      {String removeText = "Exception: "}) {
    text = text.trim();
    if (text.toLowerCase().startsWith(removeText.toLowerCase())) {
      text = text.substring(removeText.length);
    }
    return text;
  }

  // ---------------------------------------------------------------------------
  // - Gestion des listes
  // ---------------------------------------------------------------------------

  ///
  /// Outil d'ajout d'une couleur dans une liste de dictionnaire sous forme
  /// d'un dégradé entre une couleur de départ et une couleur de d'arrivée
  ///
  static List<Map<String, dynamic>> addGradientColorsToListMap(
    List<Map<String, dynamic>> maps, {
    String key = 'color',
    required Color startColor,
    required Color endColor,
  }) {
    // pas de données
    if (maps.isEmpty) {
      return maps;
    }

    // un seul élément
    if (maps.length == 1) {
      final map = Map<String, dynamic>.from(maps[0]);
      map[key] = startColor;
      maps[0] = map;
      return maps;
    }

    // plusieurs éléments
    final gradientColors = List.generate(
      maps.length,
      (index) => HSLColor.lerp(
        HSLColor.fromColor(startColor),
        HSLColor.fromColor(endColor),
        index / (maps.length - 1),
      )!
          .toColor(),
    );

    return maps.asMap().entries.map((entry) {
      final map = Map<String, dynamic>.from(entry.value);
      map[key] = gradientColors[entry.key];
      return map;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // - Gestion des couleurs
  // ---------------------------------------------------------------------------

  ///
  /// Construct a color from a hex code string, of the format #RRGGBB.
  ///
  static Color hexToColor(String code) {
    // cas du code couleur sans # au début
    if (code.startsWith("#") == false) {
      code = "#$code";
    }
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  ///
  /// Fonction de convertion d'un couleur en hexa
  ///
  static String colorToHex(Color color) {
    // extraction couleur
    final hex = color.toARGB32();

    // Extraire les composantes rouge, verte et bleue
    final red = ((0x00ff0000 & hex) >> 16).toRadixString(16).padLeft(2, '0');
    final green = ((0x0000ff00 & hex) >> 8).toRadixString(16).padLeft(2, '0');
    final blue = ((0x000000ff & hex) >> 0).toRadixString(16).padLeft(2, '0');

    // Construire la chaîne hexadécimale
    return '#$red$green$blue';
  }

  ///
  /// Récupération d'une couleur à partir d'un code hexa
  ///
  static Color getColorFromString(String item, Color defaultColor) {
    try {
      return hexToColor(item);
    } catch (e) {
      return defaultColor;
    }
  }

  ///
  /// Modification d'une couleur en plus foncée
  ///
  static Color darkenColor(Color color, {double factor = 0.1}) {
    assert(factor >= 0 && factor <= 1);

    HSLColor hsl = HSLColor.fromColor(color);
    HSLColor darkenedHsl =
        hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return darkenedHsl.toColor();
  }

  ///
  /// Modification d'une couleur en plus claire
  ///
  static Color lightenColor(Color color, {double factor = 0.1}) {
    assert(factor >= 0 && factor <= 1);

    HSLColor hsl = HSLColor.fromColor(color);
    HSLColor lightenedHsl =
        hsl.withLightness((hsl.lightness + factor).clamp(0.0, 1.0));
    return lightenedHsl.toColor();
  }

  // ---------------------------------------------------------------------------
  // - Gestion des dates
  // ---------------------------------------------------------------------------

  ///
  /// Formatage de l'heure
  ///
  static String formatTime(int timeToConvert) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timeToConvert - 1000 * 3600);
    DateFormat finalFormat = DateFormat.Hms("fr");
    return finalFormat.format(date);
  }

  ///
  /// Formatage de la date
  ///
  static String formatDateWithLocale(String dateToConvert) {
    var standardDateFormat = DateFormat("yyyy-MM-dd");

    DateTime tmp = standardDateFormat.parse(dateToConvert);
    DateFormat finalFormat = DateFormat.yMMMMd("fr");

    return finalFormat.format(tmp);
  }

  ///
  /// Formatage de la date et de l'heure
  ///
  static String formatDateTimeWithLocale(int timeToConvert) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timeToConvert * 1000);
    DateFormat dateFormat = DateFormat.MMMMEEEEd("fr");
    DateFormat timeFormat = DateFormat.Hm("fr");

    return "${dateFormat.format(date)} ${timeFormat.format(date)}";
  }

  ///
  /// Temps restant avant l'échéance à partir de la date actuelle
  ///
  static String formatTimeRemaining(
    DateTime futureDate, {
    bool showSeconds = true,
    String daysLabel = "jours",
  }) {
    final now = DateTime.now();
    final difference = futureDate.difference(now);

    if (difference.isNegative) {
      return "";
    }

    // Extraire les jours, heures, minutes et secondes restants
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    // Formater la chaîne de caractères
    if (days > 0) {
      return "$days $daysLabel, ${hours.toString().padLeft(2, '0')}:"
          "${minutes.toString().padLeft(2, '0')}"
          "${(showSeconds) ? ':${seconds.toString().padLeft(2, '0')}' : ''}";
    } else {
      return "${hours.toString().padLeft(2, '0')}:"
          "${minutes.toString().padLeft(2, '0')}"
          "${(showSeconds) ? ':${seconds.toString().padLeft(2, '0')}' : ''}";
    }
  }

  // ---------------------------------------------------------------------------
  // - Gestion des snackbars
  // ---------------------------------------------------------------------------

  ///
  /// Affichage d'une snackbar
  ///
  static void showSnackbar(BuildContext context, String text,
      {int duration = 1000}) {
    final snackBar = SnackBar(
      content: Text(text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
      duration: Duration(milliseconds: duration),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  ///
  /// Affichage d'un snackbar sans scaffold !
  ///
  static void showSnackbarContext(
    BuildContext context,
    String text, {
    String? title,
    bool success = true,
    int duration = 3000,
    VoidCallback? onClose,
    bool isDismissible = true,
    bool blockBackgroundInteraction = false,
  }) {
    // on établit une icône suivant la situation du succès
    Widget icon = (success)
        ? Icon(
            Icons.info_outline,
            size: 28,
            color: Colors.blue.shade300,
          )
        : Image.asset(
            "packages/mbtools/assets/images/etonnant.gif",
            height: 25.0,
          );

    // étude du titre de la fenêtre
    title ??= ToolsConfigApp.appName;

    // affichage de la flushbar
    Flushbar(
      title: title,
      showProgressIndicator: true,
      message: text,
      icon: icon,
      isDismissible: isDismissible,
      blockBackgroundInteraction: blockBackgroundInteraction,

      // Even the button can be styled to your heart's content
      mainButton: TextButton(
        child: Text(
          (success) ? "succeeded" : "failed",
          style: ((success)
              ? TextStyle(color: Theme.of(context).primaryColor)
              : const TextStyle(color: Colors.red)),
        ),
        onPressed: () {},
      ),
      duration: Duration(milliseconds: duration),
      onStatusChanged: (status) {
        // activation de la fonction de rappel en cas de fermeture
        if (onClose != null && status == FlushbarStatus.IS_HIDING) {
          Future.delayed(const Duration(milliseconds: 500), () {
            onClose();
          });
        }
      },
      // Show it with a cascading operator
    ).show(context);
  }

  // ---------------------------------------------------------------------------
  // - Gestion des widgets utiles
  // ---------------------------------------------------------------------------

  ///
  /// Affichage du widget de clic avec un pointeur différent
  ///
  static Widget clickableWidget({
    required Widget child,
    String? tooltip,
    MouseCursor pointer = SystemMouseCursors.click,
    GestureTapUpCallback? onTapUp,
    GestureLongPressUpCallback? onLongPressUp,
  }) {
    // check du clic
    if (onTapUp == null && onLongPressUp == null) {
      return Tooltip(
        message: tooltip ?? "",
        child: child,
      );
    }

    // gestion de l'élément clickable
    return MouseRegion(
        cursor: pointer,
        child: Tooltip(
          message: tooltip ?? "",
          child: GestureDetector(
            onTapUp: onTapUp,
            onLongPressUp: onLongPressUp,
            child: child,
          ),
        ));
  }
}
