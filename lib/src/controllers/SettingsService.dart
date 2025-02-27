import 'dart:async';
import 'package:flutter/material.dart' show Size;
// import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:pref/pref.dart';

import '../config/config.dart';
import '../controllers/controllers.dart';

///
/// Classe de raccourcie vers les configurations de l'application via les préférences ``pref`` (module)
///
class SettingsService {
  // fabrication du singleton
  static SettingsService? _instance;

  factory SettingsService() {
    _instance ??= SettingsService._();

    // since you are sure you will return non-null value, add '!' operator
    return _instance!;
  }

  ///
  /// Constructeur de subtitution pour le singleton
  ///
  SettingsService._();

  ///
  /// Fonction d'initialisation des données
  Future<void> init([Map<String, dynamic>? defaults]) async {
    // génération d'une map par défaut
    Map<String, dynamic> map = {
      // gestion utilisateur
      "currentuser_token": "",
      "currentuser_secret_key": "o4hfJumYBmuwdOa4WMuOPYSIR1abPavj",

      // gestion de la rétention du screensaver
      "wakelock_enabled": false,

      // audio
      "sound_enabled": true,
      "sound_volume": 0.8,

      // gestion de la fenêtre desktop
      "desktop_application_width": 0.0,
      "desktop_application_height": 0.0,

      // debugger / développement
      "development_api_url": "",
      "is_development_mode": false,
      "is_log_to_file": false,
      "log_level": "nolog",
      "log_pathname": "var/application-log.txt",
      "log_max_lines": 9000,
    };

    // fusion avec la map de l'utilisateur
    map = {...defaults ?? {}, ...map};

    // chargement des préférences
    _prefs = await PrefServiceShared.init(
      defaults: map,
    );

    // log level
    switch (get("log_level", "info") as String) {
      case "nolog":
        ToolsConfigApp.logger.level = LogLevel.nolog;
        break;
      case "trace":
        ToolsConfigApp.logger.level = LogLevel.trace;
        break;
      case "debug":
        ToolsConfigApp.logger.level = LogLevel.debug;
        break;
      case "info":
        ToolsConfigApp.logger.level = LogLevel.info;
        break;
      case "warn":
        ToolsConfigApp.logger.level = LogLevel.warn;
        break;
      case "error":
        ToolsConfigApp.logger.level = LogLevel.error;
        break;
      case "fatal":
        ToolsConfigApp.logger.level = LogLevel.fatal;
        break;
      default:
        ToolsConfigApp.logger.level = LogLevel.info;
    }

    // configuration du logger
    ToolsConfigApp.logger.pathname = get("log_pathname") as String;
    ToolsConfigApp.logger.logFile = get("is_log_to_file", false) as bool;
    ToolsConfigApp.logger.maxLogFileLines = get("log_max_lines", 9000) as int;
  }

  // gestion du cache
  PrefServiceShared? _prefs;

  ///
  /// Gestion du service des préférences pour l'interface graphique
  ///
  get preferencesService => _prefs;

  ///
  /// Indique si les préférences sont prêtes
  ///
  bool get isReady {
    if (_prefs == null) {
      throw Exception(
          "Preferences not set! Use await ToolsConfigApp.initSettings() before");
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // - Misc : fonctions génériques d'acquisition de préférences
  // ---------------------------------------------------------------------------

  T? get<T>(String key, [T? defaultValue]) {
    T? value = _prefs?.get(key) as T?;
    if (value == null && defaultValue != null) {
      return defaultValue;
    }
    return value;
  }

  FutureOr<bool> set<T>(String key, T value) async {
    return _prefs?.set(key, value) ?? false;
  }

  // ---------------------------------------------------------------------------
  // - Application : gestion de la fenête de l'application
  // ---------------------------------------------------------------------------

  Size getDesktopWindowsInitialSize({
    Size? initialSize,
    Size? minimumSize,
  }) {
    // récupération des valeurs avec gestion des minimas
    double w = _prefs?.get("desktop_application_width") ??
        initialSize?.width ??
        ToolsConfigApp.appDesktopWindowInitialSize.width;
    if (w <
        (minimumSize?.width ??
            ToolsConfigApp.appDesktopWindowMinimalSize.width)) {
      w = minimumSize?.width ??
          ToolsConfigApp.appDesktopWindowInitialSize.width;
    }

    // récupération des valeurs avec gestion des minimas
    double h = _prefs?.get("desktop_application_height") ??
        initialSize?.height ??
        ToolsConfigApp.appDesktopWindowInitialSize.height;
    if (h <
        (minimumSize?.height ??
            ToolsConfigApp.appDesktopWindowMinimalSize.height)) {
      h = minimumSize?.height ??
          ToolsConfigApp.appDesktopWindowInitialSize.height;
    }

    return Size(w, h);
  }

  void setDesktopWindowsInitialSize(Size value) {
    _prefs?.set("desktop_application_width", value.width);
    _prefs?.set("desktop_application_height", value.height);
  }

  void setDefaultDesktopWindowsInitialSize() {
    // mise en place des données par défaut de la taille de la fenêtre
    _prefs?.set("desktop_application_width",
        ToolsConfigApp.appDesktopWindowInitialSize.width);
    _prefs?.set("desktop_application_height",
        ToolsConfigApp.appDesktopWindowInitialSize.height);
  }

  // ---------------------------------------------------------------------------
  // - Connexion : token de connexion de l'utilisateur
  // ---------------------------------------------------------------------------

  String getCurrentUserToken() {
    return _prefs?.get("currentuser_token");
  }

  void setCurrentUserToken(String value) {
    _prefs?.set("currentuser_token", value);
  }

  String getCurrentUserSecretKey() {
    return _prefs?.get("currentuser_secret_key");
  }

  void setCurrentUserSecretKey(String value) {
    _prefs?.set("currentuser_secret_key", value);
  }

  // ---------------------------------------------------------------------------
  // - Configuration : Option : blocage de la mise en veille du device
  // ---------------------------------------------------------------------------

  bool isOptionWakelockPage() {
    return get("wakelock_enabled", false) ?? false;
  }

  void setOptionWakelockPage(bool value) {
    set("wakelock_enabled", value);
  }

  // ---------------------------------------------------------------------------
  // - Configuration : mode développeur : url de l'api
  // ---------------------------------------------------------------------------

  bool isDevelopmentMode() {
    return get("is_development_mode", false) ?? false;
  }

  void setDevelopmentMode(bool value) {
    set("is_development_mode", value);
  }

  String getDevelopmentApiUrl() {
    return get("development_api_url", "") ?? "";
  }

  void setDevelopmentApiUrl(String value) {
    set("development_api_url", value);
  }

  // ---------------------------------------------------------------------------
  // - Configuration : xxxx
  // ---------------------------------------------------------------------------

  /*
  bool? getXXX() {
    return _prefs.getBool("xxx");
  }

  void setXXX(bool value) {
    _prefs.setBool("xxx", value);
  }
  */
}
