///
/// Service d'analyse des pages vues ou événements par l'utilisateur
/// sur l'application pour le serice Matomo
///

/*
Exemple d'utilisation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MatomoAnalyticsHelper.initializeIfConsented();
  runApp(MyApp());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    MatomoAnalyticsHelper.trackPageName('HomePage');
  }

  void _onConsentGiven() {
    MatomoAnalyticsHelper.trackPageName('HomePage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: Stack(
        children: [
          const Center(child: Text('Bienvenue sur l\'app')),
          MatomoAnalyticsHelper.buildConsentBanner(onConsentGiven: _onConsentGiven),
        ],
      ),
    );
  }
}
 */

/// importation
import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../mbtools.dart';

class MatomoAnalyticsHelper {
  static bool _isPluginReady = false;
  static String _consentKey = 'matomoConsent';
  static String _siteId = "";
  static String _trackerUrl = '';
  static String? _userId;

  ///
  /// Initialize Matomo if user consented
  ///
  static Future<void> initializeIfConsented({
    required String matomoUrl,
    required String matomoSiteId,
    String consentKeyPref = "matomoConsent",
    bool autoSendAppLaunchTracking = true,
    String? userId,
  }) async {
    // check
    if (matomoUrl.isNotEmpty && matomoSiteId.isNotEmpty) {
      _isPluginReady = true;
    }

    if (consentKeyPref.trim().isEmpty) {
      consentKeyPref = "matomoConsent";
    }

    userId ??= await ToolsHelpers.getUniqueDeviceId();

    // affectation des données
    _consentKey = consentKeyPref;
    _siteId = matomoSiteId;
    _trackerUrl = matomoUrl;
    _userId = userId;

    // recherche du consentement
    if (hasConsent()) {
      await MatomoTracker.instance.initialize(
        siteId: _siteId,
        url: _trackerUrl,
        uid: _userId,
        dispatchSettings: const DispatchSettings.persistent(),
      );
      if (autoSendAppLaunchTracking) {
        trackDeviceInfo();
      }
    }
  }

  ///
  /// Store consent and initialize Matomo
  ///
  static Future<void> setConsentGiven(bool value) async {
    ToolsConfigApp.logger.i("Matomo service: consent: $value");
    ToolsConfigApp.preferences.set(_consentKey, value.toString());
    if (value) {
      // check
      if (!_isPluginReady) {
        return;
      }

      await MatomoTracker.instance.initialize(
        siteId: _siteId,
        url: _trackerUrl,
        uid: _userId,
        dispatchSettings: const DispatchSettings.persistent(),
      );

      // envoi de données
      trackDeviceInfo();
      trackEvent(
        category: 'Environment',
        action: 'AppConsent',
        name: 'User consent tracking',
      );
    }
  }

  ///
  /// Check if consent has been granted
  ///
  static bool hasConsent() {
    if (!_isPluginReady) {
      return false;
    }

    return (ToolsConfigApp.preferences.get(_consentKey, "") ?? "") == "true";
  }

  ///
  /// Track a screen
  ///
  static void trackPageName(String actionName, {String? pagePath, }) async {
    if (!_isPluginReady) {
      return;
    }

    if (!MatomoTracker.instance.initialized) {
      ToolsConfigApp.logger.w("Matomo service not initialized");
      return;
    }

    if (hasConsent()) {
      // MatomoTracker.instance.trackScreen(widgetName: screenName);
      MatomoTracker.instance.trackPageViewWithName(
        actionName: actionName,
        path: pagePath,
        // dimensions: {'dimension1': '0.0.1'}
      );
    }
  }

  ///
  /// Track an event
  /// 
  static void trackEvent({
    required String category,
    required String action,
    String? name,
    num? value,
  }) {
    if (!_isPluginReady) {
      return;
    }

    if (!MatomoTracker.instance.initialized) {
      ToolsConfigApp.logger.w("Matomo service not initialized");
      return;
    }

    if (hasConsent()) {
      // MatomoTracker.instance.trackEvent(
      //   category: category,
      //   action: action,
      //   name: name,
      //   value: value,
      // );
      MatomoTracker.instance.trackEvent(
        eventInfo: EventInfo(
          category: category,
          action: action,
          name: name,
          value: value,
        ),
        dimensions: {'dimension2': _userId ?? "guest-user"}
      );
    }
  }

  /// 
  /// Track device and environment info
  /// 
  static void trackDeviceInfo() {
    if (!_isPluginReady) {
      return;
    }

    if (!MatomoTracker.instance.initialized) {
      ToolsConfigApp.logger.w("Matomo service not initialized");
      return;
    }

    if (!hasConsent()) return;

    // récupération de information
    ToolsHelpers.getUniqueDeviceModel().then((String? data) async {
      if (data == null) return;

      // récupération des éléments
      try {
        String os = data.split(";").first;
        String model = data.split(";").last;

        final packageInfo = await PackageInfo.fromPlatform();
        final appVersion = packageInfo.version;
        final appName = packageInfo.appName;
        final packageName = packageInfo.packageName;

        // événement
        trackEvent(
          category: 'Environment',
          action: 'AppLaunch',
          name: 'Device: $model | OS: $os | App name: $appName | App version: $appVersion | App package: $packageName',
        );
      }
      catch(e) {
        return;
      }
    });
  }

  ///
  /// Returns a widget to show the consent banner
  ///
  static Widget buildConsentBanner({
    required VoidCallback onConsentGiven,
    String labelUserDisplay = 'Nous utilisons Matomo pour améliorer l\'application.\nAucune donnée personnelle n\'est collectée.',
    String labelButtonAccept = 'J\'accepte',

    // design
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 12,
    bool hasShadow = true,
    Color shadowColor = Colors.black26,
    double shadowBlurRadius = 10,
    Offset? shadowOffset = const Offset(0, 5),
    Color? buttonColor,
    Color? buttonTextColor,
    double? buttonFontSize,
    Color? textColor,
    double? textFontSize,
  }) {
    // return FutureBuilder<bool>(
    //   future: hasConsent(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState != ConnectionState.done || snapshot.data == true) {
    //       return const SizedBox.shrink();
    //     }
    //
    //     return ....
    //   },
    // );
    if (!_isPluginReady || hasConsent()) {
      return const SizedBox.shrink();
    }

    // design
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor == null ? null : Border.all(color: borderColor),
          boxShadow: hasShadow ? [
            BoxShadow(
              color: shadowColor,
              blurRadius: shadowBlurRadius,
              offset: shadowOffset ?? const Offset(0, 5),
            ),
          ] : null,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labelUserDisplay,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: textFontSize,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await setConsentGiven(true);
                onConsentGiven();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
              ),
              child: Text(
                labelButtonAccept,
                style: TextStyle(
                  color: buttonTextColor,
                  fontSize: buttonFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
