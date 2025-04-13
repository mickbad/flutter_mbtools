///
/// classe de gestion d'un thème via Riverpod
///
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbtools/mbtools.dart';

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
    () => ToolsThemeAppRiverpod());
