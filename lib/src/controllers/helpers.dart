///
/// Fonctions utilitaires
///

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mbtools/mbtools.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:path/path.dart' as p;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:toastification/toastification.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
// import 'package:html/parser.dart' as html_parser;
// import 'package:html/dom.dart' as html_dom;

///
/// Enumération des alertes
///
enum ToastFlashType { success, error, warning, info }

enum ToastFlashPosition { top, bottom, center }

///
/// Outils helpers
///
class ToolsHelpers {
  ///
  /// Récupération du répertoire d'exécution du logiciel
  ///
  static String getAppDirectory() => File(Platform.resolvedExecutable).parent.path;

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

  ///
  /// convertion en bse64 d'un fichier
  ///
  static Future<String?> encodeFileToBase64(String filePath, [String? assetsPath]) async {
    try {
      List<int> fileBytes;

      if (filePath.startsWith(assetsPath ?? 'assets/')) {
        // Chargement du fichier depuis les assets
        ByteData byteData = await rootBundle.load(filePath);
        fileBytes = byteData.buffer.asUint8List();
      } else {
        // Chargement du fichier depuis le système de fichiers
        File file = File(filePath);
        if (!file.existsSync()) return null;
        fileBytes = await file.readAsBytes();
      }

      return base64Encode(fileBytes);
    } catch (e) {
      ToolsConfigApp.logger.e("Erreur lors de l'encodage en Base64: $e");
      return null;
    }
  }

  ///
  /// Nettoyage d'un nom de fichier
  ///
  static String sanitizeFileName(String fileName) {
    // Liste des caractères interdits sur Android et iOS
    final RegExp forbiddenChars = RegExp(r'[\/:*?"<>|\\\x00]');

    // Remplacement des caractères interdits par un espace
    String sanitizedName = fileName.replaceAll(forbiddenChars, ' ');

    // Suppression des espaces multiples
    sanitizedName = sanitizedName.replaceAll(RegExp(r'\s+'), ' ');

    // Suppression des espaces en début et fin de chaîne
    return sanitizedName.trim();
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
  /// Récupération du model du device courant (système + modèle device)
  ///
  static Future<String?> getUniqueDeviceModel() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? identifier;
    String? model;
    String? type;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        identifier = androidInfo.id;
        model = androidInfo.model;
        type = "Android";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        identifier = iosInfo.identifierForVendor;
        type = "iOS";
        model = iosInfo.modelName;
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        identifier = linuxInfo.machineId;
        type = "Linux";
        model = linuxInfo.prettyName;
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macOsInfo = await deviceInfo.macOsInfo;
        identifier = macOsInfo.systemGUID;
        type = "macOS";
        model = macOsInfo.modelName;
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        identifier = windowsInfo.deviceId;
        type = "Windows";
        model = windowsInfo.productName;
      } else if (kIsWeb) {
        WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        identifier = webInfo.vendor! +
            webInfo.userAgent! +
            webInfo.hardwareConcurrency.toString();
        type = "Browser";
        model = webInfo.vendor;
      }
    } catch (e) {
      return null;
    }

    // return "$type;$model;$identifier";
    return "$type;$model";
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
  /// [encrypt] : vrai pour que le fichier soit chiffré après la lecture
  ///
  static Future<String?> downloadUrlToFile(
    String url,
    String pathname, {
    String method = 'GET',
    Map<String, String>? headers,
    Map<String, String>? formData,
    dynamic body,
    bool encrypt = false,
    String? encryptAESKey,
  }) async {
    try {
      http.Response response;

      // Vérification de la méthode
      final methodUpper = method.toUpperCase();
      if (methodUpper != 'GET' && methodUpper != 'POST') {
        throw ArgumentError('Method must be GET or POST');
      }

      // Préparation de la requête
      if (methodUpper == 'GET') {
        response = await http.get(Uri.parse(url), headers: headers);
      } else {
        if (formData != null) {
          headers ??= {};
          headers['Content-Type'] = 'application/x-www-form-urlencoded';
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: formData,
          );
        } else {
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: body,
          );
        }
      }

      // Vérifier le statut HTTP
      if (response.statusCode != 200) return null;

      // Lire les données
      Uint8List bodyBytes = response.bodyBytes;

      // Chiffrement si nécessaire
      if (encrypt) {
        bodyBytes = encryptAESBytes(bodyBytes, encryptAESKey);
      }

      // Écrire le fichier
      final file = File(pathname);
      await file.writeAsBytes(bodyBytes, flush: true);

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

  ///
  /// Fonction de récupération d'un élément aléatoire depuis une liste
  ///
  static T getRandomElement<T>(List<T> list) {
    if (list.isEmpty) {
      throw Exception('empty list!');
    }
    final random = Random();
    return list[random.nextInt(list.length)];
  }

  ///
  /// Fonction de normalisation d'un texte (sans accent et miniscule)
  ///
  static String normalize(String input) {
    final str = input.toLowerCase().trim();

    const accentMap = {
      'a': 'àâäãá',
      'e': 'éèêë',
      'i': 'îïìí',
      'o': 'ôöòóõ',
      'u': 'ûüùú',
      'c': 'ç',
    };

    String out = str;
    accentMap.forEach((key, accents) {
      out = out.replaceAll(RegExp('[$accents]'), key);
    });

    return out.replaceAll(RegExp(r"\s+"), " ");
  }

  ///
  /// Recherche complète avec scoring (tolérance aux fautes et à la case)
  ///
  /// ✅ Exemple 1 : Utilisation avec des champs d'un objet
  ///
  /// listing = fuzzySearch(
  ///   query: value,
  ///   items: widget.list,
  ///   fieldExtractor: (e) => '${e.clientName} ${e.clientEmail} ${e.quoteNumber} ${e.projectTitle}',
  /// );
  ///
  /// ✅ Exemple 2 : Si ton objet est un Map / JSON
  ///
  /// listing = fuzzySearch(
  ///   query: value,
  ///   items: myJsonList,
  ///   fieldExtractor: (map) => '${map["name"]} ${map["email"]} ${map["id"]}',
  /// );
  ///
  /// ✅ Exemple 3 : Tu veux chercher automatiquement dans toutes les valeurs d’un Map
  ///
  /// listing = fuzzySearch(
  ///   query: value,
  ///   items: myMaps,
  ///   fieldExtractor: (map) => map.values.join(" "),
  /// );
  ///
  /// ✅ Exemple 4 : Pas d’extractor → utilise toString()
  ///
  /// listing = fuzzySearch(
  ///   query: value,
  ///   items: logsList,
  /// );
  ///
  static List<T> fuzzySearch<T>({
    required String query,
    required List<T> items,
    String Function(T item)? fieldExtractor,
    double threshold = 0.25, // filtrage minimum de pertinence
  }) {
    ///
    /// Levenshtein distance (fuzzy matching) pour la recherche avec erreur de frappe
    ///
    int levenshtein(String s, String t) {
      if (s == t) return 0;
      if (s.isEmpty) return t.length;
      if (t.isEmpty) return s.length;

      final rows = s.length + 1;
      final cols = t.length + 1;

      final dist = List.generate(rows, (_) => List<int>.filled(cols, 0));

      for (int i = 0; i < rows; i++) dist[i][0] = i;
      for (int j = 0; j < cols; j++) dist[0][j] = j;

      for (int i = 1; i < rows; i++) {
        for (int j = 1; j < cols; j++) {
          final cost = s[i - 1] == t[j - 1] ? 0 : 1;

          dist[i][j] = [
            dist[i - 1][j] + 1,      // suppression
            dist[i][j - 1] + 1,      // insertion
            dist[i - 1][j - 1] + cost // substitution
          ].reduce((a, b) => a < b ? a : b);
        }
      }

      return dist[s.length][t.length];
    }

    ///
    /// Fuzzy ratio (plus le score est haut, plus c’est pertinent)
    ///
    double fuzzyScore(String query, String text) {
      // Si exact match → score très élevé
      if (text.contains(query)) return 1.0;

      // On compare query avec chaque mot du texte
      final words = text.split(' ');

      double best = 0;

      for (final w in words) {
        final d = levenshtein(query, w);
        final maxLen = w.length > query.length ? w.length : query.length;
        final score = 1 - (d / maxLen);

        if (score > best) best = score;
      }

      return best; // entre 0 et 1
    }

    // traitement de la recherche
    final normalizedQuery = normalize(query);
    final queryWords = normalizedQuery.split(" ");

    final scored = items.map((item) {
      // Extraction des champs ciblés
      final text = normalize(
        fieldExtractor != null
            ? fieldExtractor(item)
            : item.toString(), // fallback générique
      );

      double totalScore = 0;

      for (final q in queryWords) {
        totalScore += fuzzyScore(q, text);
      }

      return {'item': item, 'score': totalScore};
    }).toList();

    // On supprime les résultats trop faibles
    scored.removeWhere((Map<String, dynamic> e) => e['score'] < threshold);

    // Tri décroissant par score
    scored.sort((Map<String, dynamic> a, Map<String, dynamic> b) => b['score'].compareTo(a['score']));

    // Retourne la liste finale
    return scored.map((Map<String, dynamic> e) => e['item'] as T).toList();
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

  /// //////////////////////////////////////////////////////////////////////////
  /// - Gestion des toasts
  /// //////////////////////////////////////////////////////////////////////////

  ///
  /// Toast flash
  ///
  static String toastMe({
    required BuildContext context,
    String? title,
    dynamic message = "Merci de votre action",
    ToastFlashType flashType = ToastFlashType.success,
    ToastFlashPosition flashPosition = ToastFlashPosition.bottom,
    int duration = 5,
    bool stayDisplay = false,
    bool userCanClose = true,
  }) {
    // positionnement
    var localFlashPosition;
    switch (flashPosition) {
      case ToastFlashPosition.top:
      // flashPosition = FlashPosition.top;
        localFlashPosition = Alignment.topCenter;
        break;
      case ToastFlashPosition.bottom:
      // flashPosition = FlashPosition.bottom;
        localFlashPosition = Alignment.bottomCenter;
        break;
      case ToastFlashPosition.center:
      // flashPosition = FlashPosition.center;
        localFlashPosition = Alignment.center;
        break;
    // default:
    //   // flashPosition = FlashPosition.bottom;
    //   localFlashPosition = Alignment.bottomCenter;
    }

    // niveau d'alerte
    var localFlashType;
    Color flashColor;
    IconData flashIcon;
    switch (flashType) {
      case ToastFlashType.success:
      // flashType = FlashType.success;
        localFlashType = ToastificationType.success;
        flashColor = Colors.green;
        flashIcon = Icons.check_circle_outline;
        break;
      case ToastFlashType.warning:
      // flashType = FlashType.warning;
        localFlashType = ToastificationType.warning;
        flashColor = Colors.orange;
        flashIcon = Icons.warning;
        break;
      case ToastFlashType.error:
      // flashType = FlashType.error;
        localFlashType = ToastificationType.error;
        flashColor = Colors.red;
        flashIcon = Icons.error;
        break;
      default:
      // flashType = FlashType.success;
        localFlashType = ToastificationType.success;
        flashColor = Colors.green;
        flashIcon = Icons.check_circle_outline;
    }

    // contenu du message
    Widget description;
    if (message is String) {
      description = RichText(
        text: TextSpan(
          text: message.trim(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ToolsConfigApp.appBlackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (message is Widget) {
      description = message;
    } else {
      description = const Text("Merci de votre action");
    }

    // toast
    final ToastificationItem toast = toastification.show(
      context: context,
      type: localFlashType,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: (stayDisplay) ? null : Duration(seconds: duration),
      title: Text(
        title ?? ToolsConfigApp.appName,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: ToolsConfigApp.appBlackColor,
          fontSize: 20,
        ),
      ),
      // you can also use RichText widget for title and description parameters
      description: description,
      alignment: localFlashPosition,
      // direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      icon: Icon(flashIcon),
      primaryColor: flashColor,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        ),
      ],
      progressBarTheme: ProgressIndicatorThemeData(
        color: flashColor,
        linearTrackColor: flashColor.withValues(alpha: 0.2),
        linearMinHeight: 2,
      ),
      showProgressBar: true,
      closeButton: ToastCloseButton(
        showType: (userCanClose)
            ? CloseButtonShowType.always
            : CloseButtonShowType.none,
      ),
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: userCanClose,
      applyBlurEffect: true,
      // callbacks: ToastificationCallbacks(
      //   onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
      //   onCloseButtonTap: (toastItem) => print('Toast ${toastItem.id} close button tapped'),
      //   onAutoCompleteCompleted: (toastItem) => print('Toast ${toastItem.id} auto complete completed'),
      //   onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
      // ),
    );

    // retour de l'identifiant
    return toast.id;
  }

  ///
  /// Suppression d'un toast
  ///
  static void toastDestroy(String id) {
    toastification.dismissById(id, showRemoveAnimation: true);
  }

  ///
  /// Suppression de tous les toasts
  ///
  static void toastDestroyAll({bool delayForAnimation = true}) {
    toastification.dismissAll(delayForAnimation: delayForAnimation);
  }

  ///
  /// Les différents toast
  ///
  static String toastMeSuccess({
    required BuildContext context,
    String? title,
    required dynamic message,
    ToastFlashPosition flashPosition = ToastFlashPosition.center,
    bool stayDisplay = false,
    bool userCanClose = true,
    int duration = 5,
  }) => toastMe(
    context: context,
    title: title ?? ToolsConfigApp.appName,
    message: message,
    flashType: ToastFlashType.success,
    flashPosition: flashPosition,
    stayDisplay: stayDisplay,
    userCanClose: userCanClose,
    duration: duration,
  );

  static String toastMeError({
    required BuildContext context,
    String? title,
    required dynamic message,
    ToastFlashPosition flashPosition = ToastFlashPosition.center,
    bool stayDisplay = false,
    bool userCanClose = true,
    int duration = 5,
  }) => toastMe(
    context: context,
    title: title ?? ToolsConfigApp.appName,
    message: message,
    flashType: ToastFlashType.error,
    flashPosition: flashPosition,
    stayDisplay: stayDisplay,
    userCanClose: userCanClose,
    duration: duration,
  );

  static String toastMeWarning({
    required BuildContext context,
    String? title,
    required dynamic message,
    ToastFlashPosition flashPosition = ToastFlashPosition.center,
    bool stayDisplay = false,
    bool userCanClose = true,
    int duration = 5,
  }) => toastMe(
    context: context,
    title: title ?? ToolsConfigApp.appName,
    message: message,
    flashType: ToastFlashType.warning,
    flashPosition: flashPosition,
    stayDisplay: stayDisplay,
    userCanClose: userCanClose,
    duration: duration,
  );

  static String toastMeInfo({
    required BuildContext context,
    String? title,
    required dynamic message,
    ToastFlashPosition flashPosition = ToastFlashPosition.center,
    bool stayDisplay = false,
    bool userCanClose = true,
    int duration = 5,
  }) => toastMe(
    context: context,
    title: title ?? ToolsConfigApp.appName,
    message: message,
    flashType: ToastFlashType.info,
    flashPosition: flashPosition,
    stayDisplay: stayDisplay,
    userCanClose: userCanClose,
    duration: duration,
  );

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

  // ---------------------------------------------------------------------------
  // - Gestion de fichiers
  // ---------------------------------------------------------------------------

  ///
  /// Détermine une taille de fichier en humain
  ///
  static String humanFileSize(
    int size, {
    List<String> sizeLabels = const ['octets', 'Ko', 'Mo', 'Go', 'To'],
  }) {
    // les unités retenus
    if (sizeLabels.isEmpty) {
      sizeLabels = const ['octets', 'Ko', 'Mo', 'Go', 'To'];
    }

    // Conversion basée sur le système binaire (1024)
    const int tailleUnite = 1024;

    double sizeDbl = size.toDouble();
    int indexUnite = 0;

    while (sizeDbl >= tailleUnite && indexUnite < sizeLabels.length - 1) {
      sizeDbl /= tailleUnite;
      indexUnite++;
    }

    // Formattage du résultat avec 2 décimales
    return '${sizeDbl.toStringAsFixed(2)} ${sizeLabels[indexUnite]}';
  }

  ///
  /// Demande de sauvegarde d'un fichier
  ///
  /// [dialogTitle] can be set to display a custom title on desktop platforms.
  /// Not supported on macOS.
  ///
  /// [fileName] can be set to a non-empty string to provide a default file
  /// name. Throws an `IllegalCharacterInFileNameException` under Windows if the
  /// given [fileName] contains forbidden characters.
  ///
  /// [initialDirectory] can be optionally set to an absolute path to specify
  /// where the dialog should open. Only supported on Linux, macOS, and Windows.
  /// On macOS the home directory shortcut (~/) is not necessary and passing it will be ignored.
  /// On macOS if the [initialDirectory] is invalid the user directory or previously valid directory
  /// will be used.
  ///
  /// The file type filter [type] defaults to [FileType.any]. Optionally,
  /// [allowedExtensions] might be provided (e.g. `[pdf, svg, jpg]`). Both
  /// parameters are just a proposal to the user as the save file dialog does
  /// not enforce these restrictions.
  ///
  /// If [lockParentWindow] is set, the child window (file picker window) will
  /// stay in front of the Flutter window until it is closed (like a modal
  /// window). This parameter works only on Windows desktop.
  ///
  /// Returns `null` if aborted. Returns a [Future<String?>] which resolves to
  /// the absolute path of the selected file, if the user selected a file.
  ///
  static Future<String?> userSimpleSaveFileDialog({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    List<String>? allowedExtensions,
    bool lockParentWindow = false,
  }) async {
    return await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle ?? 'Please select an output file:',
      fileName: fileName != null ? p.basename(fileName) : null,
      initialDirectory: initialDirectory,
      type: (allowedExtensions != null) ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      lockParentWindow: lockParentWindow,
    );
  }

  ///
  /// Demande de chargement d'un ou plusieurs fichiers
  ///
  /// Pour MacOS vérifier le fichier {DebugProfile|Release}.entitlements :
  ///   <key>com.apple.security.files.user-selected.read-write</key>
  ///   <true/>
  ///
  /// Pour Android, il faut ajouter les droits and le manifest
  ///   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  ///   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
  ///
  /// Pour iOS, dans le fichier Info.plist
  ///   <key>NSPhotoLibraryUsageDescription</key>
  ///   <string>Nous avons besoin d'accéder à vos fichiers.</string>
  ///   <key>NSDocumentUsageDescription</key>
  ///   <string>Accès aux fichiers requis pour l'application.</string>
  ///
  static Future<List<Map<String, dynamic>>> userSimpleLoadFilesDialog({
    String? dialogTitle,
    String? initialDirectory,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    bool includeResultBytes = false,
    List<String> sizeLabels = const ['octets', 'Ko', 'Mo', 'Go', 'To'],
  }) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle ?? 'Please select an input file:',
      initialDirectory: initialDirectory,
      type: (allowedExtensions != null) ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );

    if (result == null) {
      return [];
    }

    // liste des fichiers
    final List<Map<String, dynamic>> output = [];
    for (final filename in result.files) {
      final Map<String, dynamic> data = {
        "name": filename.name,
        "path": filename.path,
        "size": filename.size,
        "size_human": humanFileSize(filename.size, sizeLabels: sizeLabels),
        "extension_real": filename.extension,
        "extension": filename.extension?.toLowerCase() ?? "",
        "xfile": filename.xFile,
      };

      if (includeResultBytes) {
        data["bytes"] = filename.bytes;
      }

      output.add(data);
    }

    return output;
  }

  // ---------------------------------------------------------------------------
  // - Gestion des dialogues
  // ---------------------------------------------------------------------------

  ///
  /// Boîte de dialogue d'une demande de confirmation utilisateur en fonction
  /// du device (ios, android, ...)
  ///
  static Future<bool> showConfirmDialog(
      BuildContext context, {
        String? title,
        required String message,
        String validTextLabel = "Confirmer",
        String cancelTextLabel = "Annuler",
      }) async {
    title ??= ToolsConfigApp.appName;

    if (Platform.isIOS || Platform.isMacOS) {
      return await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title!),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text(cancelTextLabel),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              isDestructiveAction: true,
              child: Text(validTextLabel),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ) ??
          false;
    } else {
      return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title!),
          content: Text(message),
          actions: [
            TextButton(
              child: Text(cancelTextLabel),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ToolsConfigApp.appRedColor),
              child: Text(validTextLabel),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ) ??
          false;
    }
  }
}
