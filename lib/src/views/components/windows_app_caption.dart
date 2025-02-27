///
/// Composant pour ajouter les boutons de gestion de la fenêtre de l'application
///

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;


import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowsAppCaption extends StatelessWidget {
  const WindowsAppCaption({super.key});

  @override
  Widget build(BuildContext context) {
    // condition de non application
    if (kIsWeb || !Platform.isWindows && !Platform.isLinux) {
      return const SizedBox(width: 1,);
    }

    // barre des boutons
    return const SizedBox(
      height: kWindowCaptionHeight,
      child: WindowCaption(
        // brightness: Theme.of(context).brightness,
        // title: const Text(appName),
      ),
    );
  }
}
