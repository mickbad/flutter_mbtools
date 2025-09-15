import 'package:flutter/material.dart';

///
/// Extensions de couleurs
///
extension ColorExtension on Color {
  ///
  /// Dérermine si la couleur est claire
  ///
  bool get isLight => computeLuminance() > 0.5;

  ///
  /// Contraste de la couleur
  ///
  Color get contrastColor => isLight ? Colors.black : Colors.white;

  ///
  /// Modification d'une couleur en plus claire ou plus foncé selon la luminance
  ///
  Color slightlyContrastedColor([double amount = .1]) {
    if (isLight) {
      return darken(amount); // Assombrir légèrement les couleurs claires
    } else {
      return lighten(amount); // Éclaircir légèrement les couleurs foncées
    }
  }

  ///
  /// Couleur plus foncée
  ///
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  ///
  /// Couleur plus claire
  ///
  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
} // fin de l'extension ColorExtension

///
/// Création d'une couleur à partir de son Hexadécimal
///
class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
