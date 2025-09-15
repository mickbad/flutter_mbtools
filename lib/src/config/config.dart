///
/// Configuration globale de l'app
///
///
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_desktop_sleep/flutter_desktop_sleep.dart';
import 'package:mbtools/src/views/components/windows_app_caption.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import "../controllers/controllers.dart";

///
/// Objet de configuration externe de la librairie
///
class ToolsConfigApp {
  // ---------------------------------------------------------------------------
  ///
  /// Outillage
  ///

  // nom de l'application
  static String appName = "Ricochets App";

  // copyright de l'application
  static String appCopyrightName = "Ricochets Développement";

  // gestion des notifications
  static final mbNotifications notifications =
      mbNotifications('mipmap/ic_launcher');

  // gestion de l'état globale de l'application
  static final GlobalKey<NavigatorState> appNavigatorKey =
      GlobalKey<NavigatorState>();

  ///
  /// Fermeture urgente de tous les services
  ///
  Future closeApp({
    Future<void> Function()? onCloseApp,
    bool returnFirstRoute = true,
  }) async {
    if (returnFirstRoute) {
      // fermeture de l'application : retour au premier écran
      appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }

    // appel des fermetures
    if (onCloseApp != null) {
      await onCloseApp();
    }
  }

  // ---------------------------------------------------------------------------
  ///
  /// Couleurs de l'applications
  ///
  static Color appPrimaryColor = const Color(0xFFC5DBDE);
  static Color appSecondaryColor = const Color(0xFF5B8AD2);
  static Color appThirdColor = const Color(0xFFD25B65);
  static Color appInvertedColor = const Color(0xFFEFEFEF);
  static Color appInactiveColor = const Color(0x766B5F5F);

  static Color appErrorColor = const Color(0xFFD32F2F);
  static Color appAlertColor = const Color(0xFFB01D1D);
  static Color appSuccessColor = const Color(0xFF409143);
  static Color appWarningColor = const Color(0xFFBF9A22);
  static Color appInfoColor = const Color(0xFF19BFBF);

  static Color appBlackColor = const Color(0xFF1B1A1A);
  static Color appWhiteColor = const Color(0xFFE7E7E7);
  static Color appRedColor = const Color(0xFFD32F2F);
  static Color appYellowColor = const Color(0xFFFFCA28);
  static Color appBlueColor = const Color(0xFF5B8AD2);
  static Color appGreenColor = const Color(0xFF43A047);
  static Color appGreyColor = const Color(0xFF6B5F5F);
  static Color appPurpleColor = const Color(0xFFA020F0);
  static Color appMagentaColor = const Color(0xFFCD1BCD);
  static Color appCyanColor = const Color(0xFF19BFBF);
  static Color appOrangeColor = const Color(0xFFCF740D);

  // ---------------------------------------------------------------------------
  ///
  /// Gestion des API
  ///

  // Clef de l'api de l'application statique
  static String appApiKey = "--";

  // url de l'api de l'application
  static String appApiURL = "http://localhost:8000/api";

  // durée maximum du cache api
  static double appApiMaxDurationCacheSeconds = 5 * 60;

  // ---------------------------------------------------------------------------
  ///
  /// Logger d'événements
  ///
  static MyAppLogger logger = MyAppLogger();

  ///
  /// initialisation d'un logger d'événements
  ///
  MyAppLogger initLogger({
    String filename = 'var/application-log.txt',
    int maxLogFileLines = 1024,
    LogLevel level = LogLevel.info,
    bool showEmojis = true,
  }) {
    logger = MyAppLogger.storeAppDocuments(
      filename: filename,
      maxLogFileLines: maxLogFileLines,
      level: level,
      showEmojis: showEmojis,
    );
    return logger;
  }

  // ---------------------------------------------------------------------------
  ///
  /// Préférences de l'application
  ///
  static SettingsService preferences = SettingsService();

  ///
  /// initialisation d'un système de préférences
  ///
  static Future<SettingsService> initSettings(
      {Map<String, dynamic>? defaults}) async {
    await preferences.init(defaults);
    return preferences;
  }

  // ---------------------------------------------------------------------------
  ///
  /// Gestion de l'application (desktop / mobile)
  ///
  static bool? _isDesktopApplication;

  ///
  /// Récupération si l'application courante est une application desktop
  ///
  static bool get isDesktopApplication {
    if (_isDesktopApplication == null) {
      // recherche de la notion
      // on détermine si on est sur une plateforme de type desktop
      if (kIsWeb) {
        _isDesktopApplication = false;
      } else {
        _isDesktopApplication =
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
      }
    }

    // retour
    return _isDesktopApplication ?? false;
  }

  ///
  /// Détermine le nom de l'os faisant tourner le programme
  ///
  static String get getPlatformName {
    if (kIsWeb) {
      return "web";
    } else if (Platform.isAndroid) {
      return "android";
    } else if (Platform.isIOS) {
      return "ios";
    } else if (Platform.isFuchsia) {
      return "fuschia";
    } else if (Platform.isLinux) {
      return "linux";
    } else if (Platform.isMacOS) {
      return "macos";
    } else if (Platform.isWindows) {
      return "windows";
    } else {
      return "";
    }
  }

  ///
  /// Gestion de l'état de l'application desktop niveau sommeil, réveil du pc
  ///
  static void setApplicationDesktopState({
    Future<void> Function()? onSleep,
    Future<void> Function()? onWokeUp,
    Future<void> Function()? onTerminateApp,
  }) {
    // exclusion des plateformes mobile
    if (!isDesktopApplication) {
      return;
    }

    FlutterDesktopSleep flutterDesktopSleep = FlutterDesktopSleep();
    flutterDesktopSleep.setWindowSleepHandler((String? s) async {
      // log
      logger.t("[setApplicationDesktopState]: $s");

      // traitement
      if (s != null) {
        if (s == 'sleep') {
          logger.i("Mise en veille de l'ordinateur");
          if (onSleep != null) {
            await onSleep();
          }
        } else if (s == 'woke_up') {
          logger.i("Réveil de l'ordinateur");
          if (onWokeUp != null) {
            await onWokeUp();
          }
        } else if (s == 'terminate_app') {
          logger.i("Arrêt de l'application par l'utilisateur");
          if (onTerminateApp != null) {
            await onTerminateApp();
          }
          flutterDesktopSleep.terminateApp();
        }
      }
    });
  }

  ///
  /// Dimensions de la fenêtre desktop
  ///
  static const Size appDesktopWindowMinimalSize = Size(450, 800);
  static final Size appDesktopWindowInitialSize =
      Size((Platform.isWindows) ? 765 : 750, 800);

  // ancienne dimensions de la fenêtre
  static Size? _oldAppDesktopWindowSize;

  ///
  /// Gestion de la fenêtre desktop de l'application
  ///
  static Future<WindowManager?> configureDesktopWindow({
    required String appName,
    Color backgroundColor = Colors.transparent,
    String? setIconAppBadgeText,
    Size? initialSize,
    Size? minimumSize,
    Size? maximumSize,
    bool isShowTitleBar = false,
  }) async {
    // vérification s'il s'agit bien d'une application desktop
    if (!isDesktopApplication) {
      return null;
    }

    // check de la précense des préférences
    preferences.isReady;

    // initialisation
    final prefInitialSize = initialSize ??
        preferences.getDesktopWindowsInitialSize(
          initialSize: initialSize,
          minimumSize: minimumSize,
        );
    logger.d("Application initialSize: $prefInitialSize");

    // Must add this line.
    await windowManager.ensureInitialized();

    // initialisation de la fenêtre
    WindowOptions windowOptions = WindowOptions(
      size: prefInitialSize,
      minimumSize: minimumSize ?? appDesktopWindowMinimalSize,
      maximumSize: maximumSize,
      center: true,
      backgroundColor: backgroundColor,
      skipTaskbar: false,

      // (Platform.isLinux) ? TitleBarStyle.normal : TitleBarStyle.hidden,
      titleBarStyle:
          (isShowTitleBar) ? TitleBarStyle.normal : TitleBarStyle.hidden,

      windowButtonVisibility: true,
      title: appName,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();

      if (Platform.isLinux) {
        windowManager.setResizable(true);
      }

      // mise en place d'un badge sur l'icône de l'application
      if (setIconAppBadgeText != null) {
        setDesktopIconAppBadge(text: setIconAppBadgeText);
      }
    });

    // retour de la fenêtre
    return windowManager;
  }

  ///
  /// Fonction interne d'effet lors d'un changement de taille de la fenêtre
  ///
  static void _onChangeDesktopWindowSize(
    Size newSize, [
    void Function(Size)? onChangeWindowSize,
  ]) {
    // mise en mémoire localement
    _oldAppDesktopWindowSize = newSize;

    // enregistrement dans les préférences de l'utilisateur
    preferences.setDesktopWindowsInitialSize(newSize);

    // intervention utilisateur
    if (onChangeWindowSize != null) {
      onChangeWindowSize(newSize);
    }
  }

  ///
  /// Application d'une dimension à l'application
  ///
  static void setDesktopWindowsSize({
    required Size size,
    WindowManager? window,
    void Function(Size)? onChangeWindowSize,
  }) {
    // exclusion des plateformes mobile
    if (!isDesktopApplication) {
      return;
    }

    // ajustement de la taille en fonction de la configuration
    double width = size.width;
    if (width < appDesktopWindowMinimalSize.width) {
      width = appDesktopWindowMinimalSize.width;
    }

    double height = size.height;
    if (height < appDesktopWindowMinimalSize.height) {
      height = appDesktopWindowMinimalSize.height;
    }

    // application de la taille de la fenêtre
    Future.delayed(const Duration(milliseconds: 100), () async {
      WindowManager app = window ?? windowManager;
      await app.setSize(Size(width, height), animate: true);

      // post traitement
      _onChangeDesktopWindowSize(
        size,
        onChangeWindowSize,
      );
    });
  }

  ///
  /// Application d'un badge à l'icône de l'application
  ///
  static void setDesktopIconAppBadge({
    String text = "",
    String? windowsIcon,
    WindowManager? window,
  }) {
    // exclusion des plateformes mobile
    if (!isDesktopApplication) {
      return;
    }

    // Exclusion de plateformes non comptabile
    if (Platform.isLinux) {
      return;
    } else if (Platform.isMacOS) {
      // affichage du badge
      (window ?? windowManager).setBadgeLabel(text);
    } else if (Platform.isWindows) {
      // chemin de l'icône à afficher dans la barre de tâche Windows
      String? pathIco;

      // utilisation du badge fourni par le programme
      if (windowsIcon != null) {
        pathIco = windowsIcon;
      }

      // Création du badge si le texte est non vide
      else if (text.isNotEmpty) {
        // détermination du badge depuis assets/images/icons/notifications/
        pathIco =
            "packages/mbtools/assets/images/notifications/windows-notifications-9p.ico";
        if (["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(text)) {
          pathIco =
              "packages/mbtools/assets/images/notifications/windows-notifications-$text.ico";
        }
      }

      // affichage du badge
      if (pathIco != null) {
        // badge
        WindowsTaskbar.setOverlayIcon(
          ThumbnailToolbarAssetIcon(pathIco),
          tooltip: text,
        );

        // flash icone de la barre de tâches
        WindowsTaskbar.setFlashTaskbarAppIcon(
          mode: TaskbarFlashMode.all | TaskbarFlashMode.timernofg,
          timeout: const Duration(milliseconds: 500),
        );

        // arrêt programmé du flash
        Future.delayed(const Duration(seconds: 3),
            () => WindowsTaskbar.resetFlashTaskbarAppIcon());
      } else {
        // annulation du badge car pas de texte
        WindowsTaskbar.resetOverlayIcon();
      }
    }
  }

  ///
  /// Observation du changement de dimension de la fenêtre
  ///
  static Widget desktopWindowSizeObserver({
    required Widget app,
    void Function(Size)? onChangeWindowSize,
  }) {
    // exclusion des plateformes mobile
    if (!isDesktopApplication) {
      return app;
    }

    // check de la précense des préférences
    preferences.isReady;

    // observer
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final newSize = mediaQuery.size;

        if (_oldAppDesktopWindowSize != newSize) {
          // La taille de la fenêtre a changé
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _onChangeDesktopWindowSize(
                    newSize,
                    onChangeWindowSize,
                  ));
        }

        // retour application
        return app;
      },
    );
  }

  ///
  /// Affichage dans la fenêtre Desktop des boutons MIN, MAX, CLOSE du
  /// système. Utile quand on n'affiche pas la barre de titre de la fenêtre
  ///
  static Widget desktopWindowShowAppCaptionIcons({
    required Widget body,
  }) {
    return Stack(
      children: [
        // Contenu de la fenêtre
        body,

        // affichage des icônes de navigation
        const WindowsAppCaption(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  ///
  /// Gestion de la mise en veille du device
  ///
  static bool isScreenSaverBlock = false;

  ///
  /// Activation de la mise en veille du device
  ///
  static Future<void> enableDeviceScreenSaver() async {
    // déblocage de la mise en veille du device
    await WakelockPlus.disable();
    isScreenSaverBlock = false;
    logger.t("[mbTools] débloquage de la mise en veille du device");
  }

  ///
  /// Désactivation de la mise en veille du device
  ///
  static Future<void> disableDeviceScreenSaver() async {
    // blocage de la mise en veille du device
    await WakelockPlus.enable();
    isScreenSaverBlock = true;
    logger.t("[mbTools] blocage de la mise en veille du device");
  }
}
