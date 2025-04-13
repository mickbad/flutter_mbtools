///
/// Service de gestion des thèmes de l'application
///
library;

/*
///
/// Riverpod Provider pour le ToolsThemeApp
///
/// TODO : inclure ceci
/// 

///
/// classe de gestion d'un thème via Riverpod
/// 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
/// Classe ToolsThemeAppRiverpod qui intègre ToolsThemeApp
///
class ToolsThemeAppRiverpod extends Notifier<ThemeData> {
  final ToolsThemeApp _toolsThemeApp = ToolsThemeApp();

  @override
  ThemeData build() {
    // On initialise avec le thème actuel depuis ToolsThemeApp
    return _toolsThemeApp.build();
  }

  ///
  /// Méthode pour changer le thème via Riverpod
  ///
  void setTheme(String themeColor, {bool dark = false}) {
    // Mise à jour dans ToolsThemeApp
    _toolsThemeApp.setTheme(
      themeColor,
      dark: dark,
    );

    // Mettre à jour l'état du thème
    state = _toolsThemeApp.getThemeFromColor(themeColor, dark);
  }

  ///
  /// Getter pour accéder à ToolsThemeApp si nécessaire
  ///
  ToolsThemeApp get toolsThemeApp => _toolsThemeApp;
}

///
/// provider pour le thème
/// 
final appThemeProvider = NotifierProvider<ToolsThemeAppRiverpod, ThemeData>(
  () => ToolsThemeAppRiverpod()
);


///
/// Dans le main.dart
/// 
void main() {
  // Activer l'application avec Riverpod
  runApp(    
    ProviderScope(
      child: MainApp(),
    )
  );
}

///
/// Gestionnaire de fenêtre principale
///
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // démarrage de l'application
    return Consumer(
      builder: (context, ref, _) {
        // Récupération et application du thème de l'application
        final themeData = ref.watch(appThemeProvider);

        final Widget app = MaterialApp(
          navigatorKey: ToolsConfigApp.appNavigatorKey,
          debugShowCheckedModeBanner: false,
          theme: themeData,
          showPerformanceOverlay: false,

          // Définition de la route à appeler à l'ouverture
          // initialRoute: '/',

          // liste de l'ensemble des routes de mon application
          // onGenerateRoute: RouteGenerator.generateRoute,

          body: const MainApp(),
        );

        return ToolsConfigApp.desktopWindowSizeObserver(
          app: app,
          onChangeWindowSize: (newSize) {
            ToolsConfigApp.logger.t("Nouvelle taille de fenêtre : $newSize");
          },
        );
      },
    );

  }
}

*/

import 'package:flutter/material.dart';
import 'package:mbtools/mbtools.dart';

const appThemeConfigKey = "theme_colors";
const appThemeConfigDarkKey = "theme_is_dark_colors";
const appThemeDefaultColors = "Blue";

///
/// Notifier pour gérer le thème
///
class ToolsThemeApp extends ChangeNotifier {
  ///
  /// Liste des couleurs disponibles
  ///
  // liste des thèmes disponibles
  static List<Map<String, dynamic>> primaryColorsListAvailable = [
    {
      "desc": "Black",
      "color_primary": ToolsHelpers.colorToHex(const Color(0xFF252525)),
      "color_secondary": ToolsHelpers.colorToHex(const Color(0xFFe12a86)),
      "color_third": ToolsHelpers.colorToHex(const Color(0xFFD25B65)),
      "color_inactive": ToolsHelpers.colorToHex(const Color(0xFFEFEFEF)),
    },
    {
      "desc": "Blue",
      "color_primary": ToolsHelpers.colorToHex(const Color(0xff0f789c)),
      "color_secondary": ToolsHelpers.colorToHex(const Color(0xFFe12a86)),
      "color_third": ToolsHelpers.colorToHex(const Color(0xFFD25B65)),
      "color_inactive": ToolsHelpers.colorToHex(const Color(0xFFEFEFEF)),
    },
    {
      "desc": "Green",
      "color_primary": ToolsHelpers.colorToHex(const Color(0xff618c14)),
      "color_secondary": ToolsHelpers.colorToHex(const Color(0xFFe12a86)),
      "color_third": ToolsHelpers.colorToHex(const Color(0xFFD25B65)),
      "color_inactive": ToolsHelpers.colorToHex(const Color(0xFFEFEFEF)),
    },
    {
      "desc": "Grey",
      "color_primary": ToolsHelpers.colorToHex(const Color(0xFF425A6A)),
      "color_secondary": ToolsHelpers.colorToHex(const Color(0xFFe12a86)),
      "color_third": ToolsHelpers.colorToHex(const Color(0xFFD25B65)),
      "color_inactive": ToolsHelpers.colorToHex(const Color(0xFFEFEFEF)),
    },
    {
      "desc": "Orange",
      "color_primary": ToolsHelpers.colorToHex(const Color(0xffe19b0f)),
      "color_secondary": ToolsHelpers.colorToHex(const Color(0xFFe12a86)),
      "color_third": ToolsHelpers.colorToHex(const Color(0xFFD25B65)),
      "color_inactive": ToolsHelpers.colorToHex(const Color(0xFFEFEFEF)),
    },
    {
      "desc": "Pink",
      "color_primary": ToolsHelpers.colorToHex(const Color(0xFFe94589)),
      "color_secondary": ToolsHelpers.colorToHex(const Color(0xff2aa1e1)),
      "color_third": ToolsHelpers.colorToHex(const Color(0xFFD25B65)),
      "color_inactive": ToolsHelpers.colorToHex(const Color(0xFFEFEFEF)),
    },
    {
      "desc": "Purple",
      "color_primary": ToolsHelpers.colorToHex(const Color(0xFF682eb9)),
      "color_secondary": ToolsHelpers.colorToHex(const Color(0xFFe12a86)),
      "color_third": ToolsHelpers.colorToHex(const Color(0xFFD25B65)),
      "color_inactive": ToolsHelpers.colorToHex(const Color(0xFFEFEFEF)),
    },
    {
      "desc": "Turquoise",
      "color_primary": ToolsHelpers.colorToHex(const Color(0xFF009999)),
      "color_secondary": ToolsHelpers.colorToHex(const Color(0xFFe12a86)),
      "color_third": ToolsHelpers.colorToHex(const Color(0xFFD25B65)),
      "color_inactive": ToolsHelpers.colorToHex(const Color(0xFFEFEFEF)),
    },
  ];

  // couleurs annexes pour mbTools
  static Color appInactiveColor = const Color(0x766B5F5F);
  static Color appErrorColor = const Color(0xFFD32F2F);
  static Color appAlertColor = const Color(0xFFB01D1D);
  static Color appRedColor = const Color(0xFFD32F2F);
  static Color appYellowColor = const Color(0xFFFFCA28);
  static Color appBlueColor = const Color(0xFF5B8AD2);
  static Color appGreenColor = const Color(0xFF43A047);
  static Color appGreyColor = const Color(0xFF6B5F5F);
  static Color appWhiteColor = const Color(0xFFFFFFFF);

  ///
  /// gestion de la récupération des couleurs
  ///
  static String currentThemeName = appThemeDefaultColors;
  Map<String, dynamic> currentThemeColors({
    String themeName = appThemeDefaultColors,
  }) {
    // Recherche du thème
    Map<String, dynamic> mytheme = primaryColorsListAvailable
        .firstWhere((map) => map["desc"] == themeName, orElse: () => {});

    // si le thème n'est pas trouvé
    if (mytheme.isEmpty) {
      mytheme = primaryColorsListAvailable.first;
    }

    // vraiment pas de thème
    if (mytheme.isEmpty) {
      throw Exception(
          "[ToolsThemeApp] : theme \"$themeName\" not found in list!");
    }

    // retour du thème
    return mytheme;
  }

  ThemeData build() {
    // Charger les préférences stockées et générer un thème initial
    return _loadThemeFromPreferences();
  }

  Future<void> setTheme(
    String themeColor, {
    bool dark = false,
  }) async {
    // Sauvegarder le thème dans shared_preferences
    final prefs = ToolsConfigApp.preferences;
    await prefs.set(appThemeConfigKey, themeColor);
    await prefs.set(appThemeConfigDarkKey, dark);

    // Mettre à jour l'état du thème
    notifyListeners();
    // state = getThemeFromColor(themeColor, dark);
  }

  ThemeData _loadThemeFromPreferences({
    String? theme,
    bool dark = false,
  }) {
    // Charger la clé stockée dans shared_preferences
    final prefs = ToolsConfigApp.preferences;
    String themeColor = prefs.get(appThemeConfigKey, theme) ?? currentThemeName;
    bool isDarkTheme = prefs.get(appThemeConfigDarkKey, dark) ?? dark;

    // affectation du nom du thème courant
    currentThemeName = themeColor;

    // retour du thème courant
    return getThemeFromColor(themeColor, isDarkTheme);
  }

  ThemeData getThemeFromColor(String currentThemeName, bool dark) {
    // Mapping des couleurs vers des thèmes
    final Map<String, dynamic> themeColors =
        currentThemeColors(themeName: currentThemeName);

    // affectation dans l'application globale
    ToolsConfigApp.appPrimaryColor = ToolsHelpers.getColorFromString(
        themeColors["color_primary"],
        const Color(0xff00aee5)); // Color(0xFF009798);
    ToolsConfigApp.appSecondaryColor = ToolsHelpers.getColorFromString(
        themeColors["color_secondary"],
        const Color(0xFFe12a86)); // Color(0xFF009798);
    ToolsConfigApp.appThirdColor = ToolsHelpers.getColorFromString(
        themeColors["color_third"], const Color(0xFFD25B65));
    ToolsConfigApp.appInactiveColor = ToolsHelpers.getColorFromString(
        themeColors["color_inactive"], const Color(0xFFEFEFEF));
    ToolsConfigApp.appErrorColor = appErrorColor;
    ToolsConfigApp.appAlertColor = appAlertColor;
    ToolsConfigApp.appRedColor = appRedColor;
    ToolsConfigApp.appYellowColor = appYellowColor;
    ToolsConfigApp.appBlueColor = appBlueColor;
    ToolsConfigApp.appGreenColor = appGreenColor;
    ToolsConfigApp.appGreyColor = appGreyColor;
    ToolsConfigApp.appWhiteColor = appWhiteColor;

    // retour du thème
    return getAppTheme(dark);
  }

  ///
  /// Gestion du thème de l'application
  ///
  /// doc : https://www.bacancytechnology.com/blog/flutter-theming
  ///
  ThemeData getAppTheme(bool isDarkTheme) {
    return ThemeData(
      scaffoldBackgroundColor:
          isDarkTheme ? Colors.grey.shade900 : Colors.white,
      useMaterial3: false,

      ///
      /// Styles des textes
      ///
      textTheme: TextTheme(
        ///
        /// styles du corps du texte
        ///
        bodyLarge: TextStyle(
          color: isDarkTheme ? Colors.white : ToolsConfigApp.appPrimaryColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: isDarkTheme ? Colors.white : ToolsConfigApp.appPrimaryColor,
          fontSize: 12,
        ),
        bodySmall: TextStyle(
          color: isDarkTheme ? Colors.white : ToolsConfigApp.appPrimaryColor,
          fontSize: 10,
        ),

        ///
        /// Styles du titre
        ///
        titleLarge: TextStyle(
          color: isDarkTheme ? Colors.white : ToolsConfigApp.appPrimaryColor,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: isDarkTheme ? Colors.white : ToolsConfigApp.appPrimaryColor,
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          color: isDarkTheme ? Colors.white : ToolsConfigApp.appPrimaryColor,
          fontSize: 11,
        ),

        ///
        /// Styles des headers
        ///
        headlineSmall: TextStyle(
          color: Colors.grey.shade100,
          fontSize: 17,
        ),
        headlineMedium: TextStyle(
          color: Colors.grey.shade100,
          fontSize: 20,
        ),
        headlineLarge: const TextStyle(
          color: Colors.white,
          fontSize: 29,
          fontWeight: FontWeight.bold,
        ),
      ).apply(
        ///
        /// Application de paramètres pour tous les styles
        ///
        // bodyColor: isDarkTheme ? Colors.white : Colors.black,
        fontFamily: 'Poppins',
        fontSizeFactor: 1.0,
      ),

      ///
      /// Styles des composants formulaire
      ///
      switchTheme: SwitchThemeData(
        // thumbColor: MaterialStateProperty.all(isDarkTheme ? Colors.orange : Colors.orangeAccent),
        // trackColor: MaterialStateProperty.all(isDarkTheme ? Colors.black : Colors.grey.shade300),
        thumbColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.red.shade300;
        }),
        trackColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.lightGreen;
          }
          return null;
        }),
        splashRadius: 30,
      ),

      ///
      /// Styles des boutons
      ///
      iconTheme: IconThemeData(
        size: 35.0,
        color: ToolsConfigApp.appSecondaryColor,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: ToolsConfigApp.appPrimaryColor,
        ),
      ),

      ///
      /// Styles des listes
      ///
      listTileTheme: ListTileThemeData(
          iconColor: isDarkTheme ? Colors.orange : Colors.purple),

      ///
      /// Styles de l'appbar de l'application
      ///
      appBarTheme: AppBarTheme(
          backgroundColor: isDarkTheme ? Colors.black : Colors.white,
          iconTheme: IconThemeData(
              color: isDarkTheme ? Colors.white : Colors.black54)),
    );
  }
}
