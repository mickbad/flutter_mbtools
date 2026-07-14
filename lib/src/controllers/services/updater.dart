import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../../mbtools.dart';

// ---------------------------------------------------------------------------
// AppUpdateChecker
// ---------------------------------------------------------------------------
/*
  Classe statique pour vérifier les mises à jour de l'application.

  USAGE DANS main() :
    final navKey = GlobalKey<NavigatorState>();
    AppUpdateChecker.init(
      navigatorKey : navKey,
      onJsonDownloadResults: (UpdateDownloadResults results) {}, // si null, l'url est envoyé au navigateur de l'utilisateur
      jsonUrl      : 'https://example.com/updates.json', // desktop/web
      appStoreId   : '123456789',                        // iOS
      androidId    : 'com.example.app',                  // Android
      beta         : false,
      lang         : 'fr',
      autoStartCheck : true,
    );
    runApp(MyApp(navigatorKey: navKey));

  FORMAT JSON attendu (tableau, versions du plus récent au plus ancien) :
    [
      {
        "version"   : "2.5.0+2",
        "mandatory" : false,
        "beta"      : true,
        "title"     : "Titre universel",           // string OU {"fr":"…","en":"…"}
        "message"   : {"fr": "…", "en": "…"},     // string OU dict
        "url"       : {"macos":"…","linux":"…","windows":"…"}
      },
      …
    ]

  dans la fonction de rappel onJsonDownloadResults, on peut traiter les données téléchargés
  ou alors directement lancer l'installation du logiciel :

    AppUpdateChecker.init(
        navigatorKey: ToolsConfigApp.appNavigatorKey,
        jsonUrl: "http://127.0.0.1/mbtools-update.json",
        beta: ToolsConfigApp.preferences.get("updates_beta_enabled", false) as bool,
        autoStartCheck: ToolsConfigApp.preferences.get("updates_auto_enabled", false) as bool,
        lang: "en",

        // on télécharge et on exécute le fichier de mise à jour
        onJsonDownloadResults: (results) async {
          ToolsConfigApp.logger.i("Update found in \"${results.url}\"");

          try {
            // exécution du fichier de mise à jour puis quitte le programme
            await results.saveAndExecute(
              quitSoftware: true, // default: true
              delayQuit: const Duration(seconds: 3), // default: 2 seconds
            );
          } catch (e) {
            ToolsConfigApp.logger.e("Updater Error: ${e.toString()}");

            try {
              BuildContext context = ToolsConfigApp.appNavigatorKey.currentContext!;
              ToolsHelpers.showSnackbarContext(
                context,
                "Updater Error: ${e.toString()}",
                success: false,
              );
            } catch(_) {}
          }
        }
      );
 */
// ---------------------------------------------------------------------------

/// fonction de rappel pour un téléchargement de contenu d'un fichier JSON
typedef JsonDownloadResults = void Function(UpdateDownloadResults results);

/// class updater
class AppUpdateChecker {
  // -------------------------------------------------------------------------
  // Configuration
  // -------------------------------------------------------------------------

  static GlobalKey<NavigatorState>? _navigatorKey;
  static final Completer<void> _ready = Completer<void>();

  /// URL du fichier JSON de versions (desktop / web)
  static String? _jsonUrl;
  static JsonDownloadResults? _onJsonDownloadResults;

  /// Identifiant numérique App Store (iOS / iPadOS / macOS via App Store)
  static String? _appStoreId;

  /// Bundle ID pour le Google Play Store (Android)
  static String? _androidBundleId;

  /// Afficher les versions beta ?
  static bool _beta = false;

  /// Langue préférée pour title/message du JSON
  static String _lang = 'en';

  /// Délai avant le premier check
  static Duration _initialDelay = const Duration(seconds: 10);

  /// Intervalle entre les checks suivants
  static Duration _checkInterval = const Duration(hours: 2);

  // ---- Textes affichés dans la boîte de dialogue (tous personnalisables) ---
  static String textUpdateAvailable = 'Update available';
  static String textLater = 'Later';
  static String textUpdate = 'Update Now!';
  static String textCurrentVersion = 'Current';
  static String textBetaLabel = 'beta';

  // options
  static bool _isDialogDisplay = false;

  // -------------------------------------------------------------------------
  // Initialisation
  // -------------------------------------------------------------------------

  /// À appeler dans main(), AVANT runApp().
  ///
  /// [navigatorKey]   Clef du Navigator global (injectée dans MaterialApp / CupertinoApp).
  /// [onJsonDownloadResults] Fonction de rappel pour un téléchargement de contenu d'un fichier JSON.
  /// [jsonUrl]        URL du JSON de versions, obligatoire pour desktop/web.
  /// [appStoreId]     Identifiant numérique App Store (iOS/iPadOS).
  /// [androidBundleId] Package name Android (com.example.app).
  /// [beta]           true → inclure les versions beta dans la recherche.
  /// [lang]           Code langue ISO 639-1 ('fr', 'en', …).
  /// [initialDelay]   Délai avant le 1er check.
  /// [checkInterval]  Intervalle entre les checks.
  /// [autoStartCheck] true → démarrer les checks automatiquement.
  static void init({
    required GlobalKey<NavigatorState> navigatorKey,
    JsonDownloadResults? onJsonDownloadResults,
    String? jsonUrl,
    String? appStoreId,
    String? androidBundleId,
    bool beta = false,
    String lang = 'en',
    Duration initialDelay = const Duration(seconds: 5),
    Duration checkInterval = const Duration(hours: 2),
    bool autoStartCheck = true,
  }) {
    _navigatorKey = navigatorKey;
    _jsonUrl = jsonUrl;
    _appStoreId = appStoreId;
    _androidBundleId = androidBundleId;
    _beta = beta;
    _lang = lang;
    _initialDelay = initialDelay;
    _checkInterval = checkInterval;
    _onJsonDownloadResults = onJsonDownloadResults;

    // On attend que l'arbre de widgets soit prêt avant de démarrer les checks.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_ready.isCompleted) _ready.complete();

      // démarrage des checks
      if (autoStartCheck) {
        _startChecking();
      }
    });
  }

  // -------------------------------------------------------------------------
  // Accesseurs dynamiques (modifiables à tout moment)
  // -------------------------------------------------------------------------

  /// Active / désactive le mode beta pendant l'exécution de l'app.
  static void setBeta(bool value) => _beta = value;

  /// Change la langue pendant l'exécution de l'app.
  static void setLang(String lang) => _lang = lang;

  // -------------------------------------------------------------------------
  // Boucle de vérification
  // -------------------------------------------------------------------------

  static void _startChecking() async {
    // pas de mode web actif car pas de gestion de version
    if (kIsWeb) return;

    await Future.delayed(_initialDelay);
    await _checkForUpdate();

    Timer.periodic(_checkInterval, (_) => _checkForUpdate());
  }

  /// Vérifie manuellement la disponibilité d'une mise à jour.
  /// Peut être appelé depuis n'importe où dans l'application.
  static Future<bool> checkNow() async {
    // pas de mode web actif car pas de gestion de version
    if (kIsWeb) return false;

    await _ready.future;
    return await _checkForUpdate();
  }

  static Future<bool> _checkForUpdate() async {
    // si le dialog est déjà affiché, on ne fait rien
    if (_isDialogDisplay) return false;

    // log
    ToolsConfigApp.logger.i("[AppUpdateChecker] Checking for new update...");

    try {
      // récupération des éléments du package courant
      final (PackageInfo info, String versionString) = await getCurrentVersion();
      final currentVersion = info.version;
      final currentBuild = int.tryParse(info.buildNumber) ?? 1;

      // log
      ToolsConfigApp.logger.i("[AppUpdateChecker] Current version: $currentVersion+$currentBuild");

      if (Platform.isIOS) {
        await _checkAppStore(currentVersion, currentBuild);
      } else if (Platform.isAndroid) {
        await _checkPlayStore(currentVersion, currentBuild);
      } else {
        await _checkJson(currentVersion, currentBuild);
      }

      // si on arrive ici c'est qu'une mise à jour est proposé
      return true;
    } catch (e) {
      // pas de mise à jour proposé ou erreur pendant l'acquisition
      ToolsConfigApp.logger.w('[AppUpdateChecker] ${e.toString().replaceFirst("Exception:", "").trim()}');
      return false;
    }
  }

  ///
  /// Récupération des informations de l'application
  /// retourne les informations du package et la version courante sous forme de String
  ///
  static Future<(PackageInfo, String)> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;
    final currentBuild = int.tryParse(info.buildNumber) ?? 1;

    return (info, "$currentVersion+$currentBuild");
  }

  // -------------------------------------------------------------------------
  // Vérification App Store (iOS)
  // -------------------------------------------------------------------------

  static Future<void> _checkAppStore(String currentVersion, int currentBuild) async {
    if (_appStoreId == null) return;

    final uri = Uri.parse(
        'https://itunes.apple.com/lookup?id=$_appStoreId&country=fr');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch App Store data: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) {
      throw Exception('No results found in App Store data');
    }

    final storeVersion = results.first['version'] as String?;
    if (storeVersion == null) {
      throw Exception('No version found in App Store data');
    }

    if (_isNewer(storeVersion, 1, currentVersion, currentBuild)) {
      // log
      ToolsConfigApp.logger.i('[AppUpdateChecker] Update available: $storeVersion');

      final storeUrl = results.first['trackViewUrl'] as String? ?? '';
      await _showDialog(
        title: textUpdateAvailable,
        message: '',
        currentVersion: currentVersion,
        newVersion: storeVersion,
        isBeta: false,
        mandatory: false,
        downloadUrl: storeUrl,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Vérification Play Store (Android)
  // -------------------------------------------------------------------------

  static Future<void> _checkPlayStore(String currentVersion, int currentBuild) async {
    if (_androidBundleId == null) return;

    // Le Play Store n'a pas d'API publique officielle.
    // On scrape la page HTML (technique courante, fragile mais fonctionnelle).
    final uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$_androidBundleId&hl=fr');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch Play Store data: ${response.statusCode}');
    }

    // Extraction de la version via le pattern standard du Play Store.
    final regex = RegExp(r'\[\[\["(\d+\.\d+[\.\d]*)"\]\]');
    final match = regex.firstMatch(response.body);
    final storeVersion = match?.group(1);
    if (storeVersion == null) {
      throw Exception('No version found in Play Store data');
    }

    if (_isNewer(storeVersion, 1, currentVersion, currentBuild)) {
      // log
      ToolsConfigApp.logger.i('[AppUpdateChecker] Update available: $storeVersion');

      final storeUrl =
          'https://play.google.com/store/apps/details?id=$_androidBundleId';
      await _showDialog(
        title: textUpdateAvailable,
        message: '',
        currentVersion: currentVersion,
        newVersion: storeVersion,
        isBeta: false,
        mandatory: false,
        downloadUrl: storeUrl,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Vérification JSON (desktop / web)
  // -------------------------------------------------------------------------

  static Future<void> _checkJson(String currentVersion, int currentBuild) async {
    if (_jsonUrl == null) return;

    final response = await http.get(Uri.parse(_jsonUrl!));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch JSON data: ${response.statusCode}');
    }

    final List<dynamic> versions = json.decode(response.body);

    // Sélectionne la version cible :
    //   • mode beta  → la plus haute avec beta == true  (ou stable si aucune)
    //   • mode stable → la plus haute avec beta != true
    _VersionEntry? target;
    String downloadUrl = "";
    String remoteVersionParse = currentVersion; // numéro de version trouvé pendant l'exploration du json
    int remoteBuildParse = currentBuild; // numéro de build trouvé pendant l'exploration du json
    for (final raw in versions) {
      _VersionEntry? currentTarget;
      final entry = _VersionEntry.fromJson(raw as Map<String, dynamic>);
      final isBeta = entry.beta;

      // Filtre selon le mode beta
      if (!_beta && isBeta) continue;

      // On prend la première entrée valide (le JSON est supposé trié du plus
      // récent au plus ancien). En mode beta, si la première entrée beta
      // n'est pas trouvée on continue pour trouver une stable.
      if (_beta && isBeta) {
        currentTarget = entry;
      }
      else if (!isBeta) {
        currentTarget = entry;
      }

      // check
      if (currentTarget == null) continue;

      // récupération de la version target
      final versionParts = currentTarget.version.split('+');
      final remoteCurrentVersion = versionParts[0];
      final remoteCurrentBuild = versionParts.length > 1 ? int.tryParse(versionParts[1]) ?? 1 : 1;

      // Récupère l'URL de téléchargement pour la plateforme courante
      final platformKey = _platformKey();
      final currentDownloadUrl = currentTarget.url[platformKey] ?? '';

      // avons nous trouvé une version plus haute ?
      if (currentDownloadUrl.isNotEmpty && _isNewer(remoteCurrentVersion, remoteCurrentBuild, remoteVersionParse, remoteBuildParse)) {
        remoteVersionParse = remoteCurrentVersion;
        remoteBuildParse = remoteCurrentBuild;
        downloadUrl = currentDownloadUrl;
        target = currentTarget;
      }
    }

    // Si aucune stable, prendre la première en mode beta
    // target ??= versions.isNotEmpty
    //     ? _VersionEntry.fromJson(versions.first as Map<String, dynamic>)
    //     : null;

    if (target == null) {
      throw Exception('No update available');
    }

    // final versionParts = target.version.split('+');
    // final remoteVersion = versionParts[0];
    // final remoteBuild = versionParts.length > 1 ? int.tryParse(versionParts[1]) ?? 1 : 1;
    //
    // if (!_isNewer(remoteVersion, remoteBuild, currentVersion, currentBuild)) {
    //   throw Exception('No update available!');
    // }

    // log
    ToolsConfigApp.logger.i('[AppUpdateChecker] Update available: ${target.version}');

    // affichage du dialog
    await _showDialog(
      title: _localize(target.title, defaultValue: textUpdateAvailable),
      message: _localize(target.message),
      currentVersion: '$currentVersion+$currentBuild',
      newVersion: target.version,
      isBeta: target.beta,
      mandatory: target.mandatory,
      downloadUrl: downloadUrl,
      onJsonDownloadResults: _onJsonDownloadResults,
    );
  }

  // -------------------------------------------------------------------------
  // Utilitaires
  // -------------------------------------------------------------------------

  /// Compare deux versions sémantiques + numéro de build.
  /// Retourne true si [remoteVersion]+[remoteBuild] > [localVersion]+[localBuild].
  static bool _isNewer(String remoteVersion, int remoteBuild, String localVersion, int localBuild) {
    final remote = _parseVersion(remoteVersion, remoteBuild);
    final local = _parseVersion(localVersion, localBuild);

    for (var i = 0; i < remote.length; i++) {
      if (i >= local.length) return true;
      if (remote[i] > local[i]) return true;
      if (remote[i] < local[i]) return false;
    }
    return false;
  }

  static List<int> _parseVersion(String version, int build) {
    final parts = version.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    parts.add(build);
    return parts;
  }

  /// Retourne la clef plateforme pour le dict "url" du JSON.
  static String _platformKey() {
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }

  /// Résout un champ qui peut être un String ou un Map<langue, String>.
  static String _localize(dynamic field, {String? defaultValue}) {
    if (field == null) return defaultValue ?? '';
    if (field is String) return field;
    if (field is Map) {
      // Langue demandée
      if (field.containsKey(_lang)) return field[_lang] as String;
      // Fallback : première entrée du dict
      return field.values.first as String? ?? defaultValue ?? '';
    }
    return defaultValue ?? '';
  }

  // -------------------------------------------------------------------------
  // Boîte de dialogue
  // -------------------------------------------------------------------------

  static Future<void> _showDialog({
    required String title,
    required String message,
    required String currentVersion,
    required String newVersion,
    required bool isBeta,
    required bool mandatory,
    required String downloadUrl,
    JsonDownloadResults? onJsonDownloadResults,
  }) async {
    await _ready.future;

    final context = _navigatorKey?.currentContext;
    if (context == null) {
      ToolsConfigApp.logger.e('[AppUpdateChecker] No context available for internal dialog!');
      return;
    }

    final isApple = Platform.isIOS || Platform.isMacOS;

    // marque le dialog comme affiché
    _isDialogDisplay = true;

    // Empêche la fermeture par swipe / touche Retour si mandatory
    await showDialog<void>(
      context: context,
      barrierDismissible: !mandatory,
      builder: (_) => PopScope(
        canPop: !mandatory,
        child: isApple
            ? _CupertinoUpdateDialog(
          title: title.isEmpty ? textUpdateAvailable : title,
          message: message,
          currentVersion: currentVersion,
          newVersion: newVersion,
          isBeta: isBeta,
          mandatory: mandatory,
          downloadUrl: downloadUrl,
          onJsonDownloadResults: onJsonDownloadResults,
        )
            : _MaterialUpdateDialog(
          title: title.isEmpty ? textUpdateAvailable : title,
          message: message,
          currentVersion: currentVersion,
          newVersion: newVersion,
          isBeta: isBeta,
          mandatory: mandatory,
          downloadUrl: downloadUrl,
          onJsonDownloadResults: onJsonDownloadResults,
        ),
      ),
    );

    // fin de dialogue
    _isDialogDisplay = false;
  }
}

// ---------------------------------------------------------------------------
// Modèle interne d'une entrée JSON
// ---------------------------------------------------------------------------

class _VersionEntry {
  final String version;
  final bool mandatory;
  final bool beta;
  final dynamic title;   // String ou Map
  final dynamic message; // String ou Map
  final Map<String, dynamic> url;

  const _VersionEntry({
    required this.version,
    required this.mandatory,
    required this.beta,
    this.title,
    this.message,
    required this.url,
  });

  factory _VersionEntry.fromJson(Map<String, dynamic> json) => _VersionEntry(
    version: json['version'] as String? ?? '',
    mandatory: json['mandatory'] as bool? ?? false,
    beta: json['beta'] as bool? ?? false,
    title: json['title'],
    message: json['message'],
    url: (json['url'] as Map<String, dynamic>?) ?? {},
  );
}

// ---------------------------------------------------------------------------
// Boîte de dialogue Material (Android / Windows / Linux)
// ---------------------------------------------------------------------------

class _MaterialUpdateDialog extends StatelessWidget {
  final String title;
  final String message;
  final String currentVersion;
  final String newVersion;
  final bool isBeta;
  final bool mandatory;
  final String downloadUrl;
  final JsonDownloadResults? onJsonDownloadResults;

  const _MaterialUpdateDialog({
    required this.title,
    required this.message,
    required this.currentVersion,
    required this.newVersion,
    required this.isBeta,
    required this.mandatory,
    required this.downloadUrl,
    required this.onJsonDownloadResults,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── En-tête coloré ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.primary.withValues(alpha: .75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Icon(Icons.arrow_circle_down, color: cs.onPrimaryContainer, size: 32),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimaryContainer,
                  ),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Corps ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.isNotEmpty) ...[
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withValues(alpha: .8),
                    ),
                    maxLines: 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                ],
                _VersionBadge(
                  currentVersion: currentVersion,
                  newVersion: newVersion,
                  isBeta: isBeta,
                ),
              ],
            ),
          ),

          // ── Boutons ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!mandatory)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppUpdateChecker.textLater),
                  ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    _launch(downloadUrl, onJsonDownloadResults: onJsonDownloadResults);

                    // fermeture du dialogue seulement si la mise à jour n'est pas obligatoire
                    if (!mandatory) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(AppUpdateChecker.textUpdate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Boîte de dialogue Cupertino (iOS / macOS)
// ---------------------------------------------------------------------------

class _CupertinoUpdateDialog extends StatelessWidget {
  final String title;
  final String message;
  final String currentVersion;
  final String newVersion;
  final bool isBeta;
  final bool mandatory;
  final String downloadUrl;
  final JsonDownloadResults? onJsonDownloadResults;

  const _CupertinoUpdateDialog({
    required this.title,
    required this.message,
    required this.currentVersion,
    required this.newVersion,
    required this.isBeta,
    required this.mandatory,
    required this.downloadUrl,
    required this.onJsonDownloadResults,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          const Icon(
            Icons.arrow_circle_down,
            size: 30,
            color: CupertinoColors.systemBlue,
          ),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            if (message.isNotEmpty) ...[
              Text(message, style: const TextStyle(fontSize: 13), maxLines: 15, overflow: TextOverflow.ellipsis,),
            ],
            _VersionBadge(
              currentVersion: currentVersion,
              newVersion: newVersion,
              isBeta: isBeta,
            ),
          ],
        ),
      ),
      actions: [
        if (!mandatory)
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppUpdateChecker.textLater),
          ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            _launch(downloadUrl, onJsonDownloadResults: onJsonDownloadResults);

            // fermeture du dialogue seulement si la mise à jour n'est pas obligatoire
            if (!mandatory) {
              Navigator.of(context).pop();
            }
          },
          child: Text(AppUpdateChecker.textUpdate),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Widget partagé : affichage des versions
// ---------------------------------------------------------------------------

class _VersionBadge extends StatelessWidget {
  final String currentVersion;
  final String newVersion;
  final bool isBeta;

  const _VersionBadge({
    required this.currentVersion,
    required this.newVersion,
    required this.isBeta,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppUpdateChecker.textCurrentVersion,
                style: TextStyle(
                    fontSize: 12, color: cs.onSurface.withValues(alpha: .5))),
            const SizedBox(width: 6),
            Text(currentVersion,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 16, color: cs.primary),
            ),
            Text(newVersion,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.primary)),
            if (isBeta) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.tertiary.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppUpdateChecker.textBetaLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.tertiary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper : ouvre l'URL de téléchargement
// ---------------------------------------------------------------------------

///
/// Objet de récupération des contenus de fichiers téléchargé
///
class UpdateDownloadResults {
  final Uri uri;
  final String url;
  final int statusCode;
  final String? text;
  final Uint8List bytes;
  final Map<String, String> headers;
  final String? err;

  UpdateDownloadResults({
    required this.uri,
    required this.url,
    required this.statusCode,
    required this.bytes,
    required this.headers,
    this.text,
    this.err,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300 && err == null;

  ///
  /// Sauvegarde le contenu téléchargé dans un fichier avec auto création du
  /// répertoire de stockage
  ///
  void saveTo(String path, {bool setExecuteMode = true}) {
    if (!isSuccess) {
      throw Exception("Saving failed: bad download: $err",);
    }

    ToolsConfigApp.logger.i("[AppUpdateChecker] try to save update in $path");

    final file = File(path);

    // suppression du fichier d'origine si existe
    if (file.existsSync()) {
      try {
        file.deleteSync();
      } catch(_) {}
    }

    // Création du dossier parent si nécessaire
    final parent = file.parent;
    if (!parent.existsSync()) {
      parent.createSync(recursive: true);
    }

    // écriture
    file.writeAsBytesSync(bytes);

    // Ajout du droit d'exécution sur Unix
    if (setExecuteMode && !Platform.isWindows) {
      final result = Process.runSync(
        'chmod',
        ['+x', file.path],
      );

      if (result.exitCode != 0) {
        throw Exception(
          "Cannot set executable permission: ${result.stderr}",
        );
      }
    }
  }

  ///
  /// Demande à l'utilisateur l'emplacement de la sauvegarde du fichier
  /// téléchargé
  ///
  Future<void> askToSaveDestination({
    String? dialogTitle,
    String successLabel = "Update file has been saved."
  }) async {
     // nom par défaut si rien ne colle
    final defaultFileName = (Platform.isWindows) ? "ricochets-download.exe": "ricochets-download.tmp";

    // Récupère le dernier élément du chemin (https://domain/path/to/test.exe -> test.exe)
    var fileName = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : defaultFileName;

    // Sécurité : évite un nom vide
    if (fileName.isEmpty) {
      fileName = defaultFileName;
    }

    // demande de localisation de la sauvegarde
    final path = await ToolsHelpers.userSimpleSaveFileDialog(
      dialogTitle: dialogTitle,
      fileName: fileName,
    );

    if (path == null) {
      return;
    }

    // sauvegarde du contenu dans le disque
    saveTo(path, setExecuteMode: true);

    // information utilisateur
    ToolsHelpers.showSnackbarContext(
      successLabel,
      success: true,
    );
  }

  ///
  /// Exécute un fichier comme un programme autonome
  ///
  Future<void> saveAndExecute({
    String? path,
    List<String> arguments = const [],
    bool quitSoftware = true,
    Duration? delayQuit,
  }) async {
    // [path] est null, on détermine un lieu temporaire
    if (path == null) {
      // nom par défaut si rien ne colle
      final defaultFileName = (Platform.isWindows) ? "ricochets-download.exe": "ricochets-download.tmp";

      // Récupère le dernier élément du chemin (https://domain/path/to/test.exe -> test.exe)
      var fileName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : defaultFileName;

      // Sécurité : évite un nom vide
      if (fileName.isEmpty) {
        fileName = defaultFileName;
      }

      // fabrication du lien de sauvegarde
      // path = await ToolsHelpers.realDownloadsOrTmpPathname(fileName);
      path = "${Directory.systemTemp.path}${Platform.pathSeparator}$fileName";
    }

    // sauvegarde du contenu dans le disque
    saveTo(path, setExecuteMode: true);

    try {
      // démarrage du process en mode détaché pour pouvoir interagir ensuite
      ToolsConfigApp.logger.i("[AppUpdateChecker] try to execute update!");
      await Process.start(
        path,
        arguments,
        mode: ProcessStartMode.detached,
      );
    }
    catch(e) {
      // on est empêché d'exécuter le logiciel, on ouvre avec la méthode système
      try {
        ToolsConfigApp.logger.w("[AppUpdateChecker] failed to execute update: $e");
        ToolsConfigApp.logger.i("[AppUpdateChecker] try to open update!");
        ToolsHelpers.openDocumentDesktopNative(path);
      } catch(e2) {
        throw Exception("Failed to execute or open $path");
      }
    }

    // fermeture du logiciel courant après une durée déterminée
    if (quitSoftware) {
      Future.delayed(delayQuit ?? const Duration(seconds: 2), () {
        ToolsConfigApp.logger.i("[AppUpdateChecker] Quit software after execute update!");
        exit(0);
      });
    }
  }
}

///
/// Lancement d'un téléchargement d'une url
/// si [onJsonDownloadResults] est null, on ouvre le navigateur par défaut de l'utilisateur
/// pour récupérer la mise à jour ; l'utilisateur final est responsable du traitement
/// Dans le cas contraire, la fonction de rappel est appelé après le téléchargement
/// de l'url demandée pour que le développeur de l'outil puisse agir dans son
/// logiciel.
///
Future<void> _launch(String url, {
  required JsonDownloadResults? onJsonDownloadResults,
}) async {
  // mini check
  if (url.isEmpty) return;

  // procédure de lanacement via le navigateur
  if (onJsonDownloadResults == null) {
    ToolsConfigApp.logger.i("[AppUpdateChecker] launch url update on browser!");
    ToolsHelpers.launchWeb(url: url);
    return;
  }

  /// procédure de téléchargement du contenu de l'url
  // variables de récupération
  Uri? uri;
  int statusCode = 500;
  Uint8List bytes = Uint8List.fromList([]);
  String? text;
  Map<String, String> headers = {};
  String? err = "no connexion";

  ToolsConfigApp.logger.i("[AppUpdateChecker] try to download update!");

  try {
    // récupération du contenu de la ressource
    uri = Uri.parse(url);
    final response = await http.get(
      uri,
      headers: {
        'User-Agent': ToolsHelpers.randomUserAgent(),
        'Accept-Language': 'fr-FR,fr;q=0.9',
      },
    );

    // récupération des données
    statusCode = response.statusCode;
    bytes = response.bodyBytes;
    headers = response.headers;

    // Tentative de décodage texte
    try {
      text = response.body;
    } catch (_) {
      text = null;
    }

    // tout va bien
    err = null;

    ToolsConfigApp.logger.i("[AppUpdateChecker] download update success!");
  }
  catch (e) {
    // erreur ?
    ToolsConfigApp.logger.w("[AppUpdateChecker] failed to download update: $e");
    err = e.toString();
  }

  // fabrication de la chaîne
  final results = UpdateDownloadResults(
    uri: uri ?? Uri.parse("http://localhost/"),
    url: url,
    statusCode: statusCode,
    text: text,
    bytes: bytes,
    headers: headers,
    err: err,
  );

  // lancement de la fonction de rappel
  onJsonDownloadResults(results);
}
