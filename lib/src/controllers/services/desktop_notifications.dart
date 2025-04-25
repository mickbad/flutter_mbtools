import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:mbtools/mbtools.dart';

///
/// Objet de gestion des notifications sur le desktop
/// add, show, close, destroy
///
class DesktopNotifications {
  ///
  /// Indicateur d'initialisation
  ///
  static bool _isSetupOk = false;

  ///
  /// Liste des notifications gérées par le système
  ///
  static final List<LocalNotification> _notificationsList = [];

  ///
  /// Initialisation du système de notification
  ///
  static Future<bool> initNotificationSystem() async {
    if (_isSetupOk) {
      return _isSetupOk;
    }

    await localNotifier.setup(
      appName: ToolsConfigApp.appName.replaceAll(" ", "_"),
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
    _isSetupOk = true;
    return _isSetupOk;
  }

  ///
  /// Affichage d'une notification sur le système
  ///
  static String? displayNotification({
    // configuration
    required String title,
    String? subtitle,
    required String body,
    bool silent = false,
    List<String>? actions,

    // gestion d'un timeout de notification
    Duration? waitBeforeShow,
    Duration? timeout,

    // listeners
    VoidCallback? onNotificationShow,
    ValueChanged<LocalNotificationCloseReason>? onNotificationClose,
    VoidCallback? onNotificationClick,
    ValueChanged<int>? onNotificationClickAction,
  }) {
    // check initialisation des notifications
    if (!_isSetupOk) {
      return null;
    }

    // création des actions à la notification
    final List<LocalNotificationAction> listActions = [];
    if (actions != null) {
      for (String a in actions) {
        listActions.add(LocalNotificationAction(
          text: a,
        ));
      }
    }

    // Création de la notification
    LocalNotification notification = LocalNotification(
      title: title,
      subtitle: subtitle,
      body: body,
      silent: silent,
      actions: listActions,
    );

    // configuration des listeners
    notification.onShow = () {
      ToolsConfigApp.logger
          .t("[Notification #${notification.identifier}] show");
      if (onNotificationShow != null) {
        onNotificationShow();
      }
    };

    notification.onClose = (closeReason) {
      ToolsConfigApp.logger.t(
          "[Notification #${notification.identifier}] closing with reason: $closeReason");

      // Supprime les notifications correspondant à l'identifiant
      _notificationsList.removeWhere(
        (n) => n.identifier == notification.identifier,
      );

      // callback
      if (onNotificationClose != null) {
        onNotificationClose(closeReason);
      }
    };

    notification.onClick = () {
      ToolsConfigApp.logger
          .t("[Notification #${notification.identifier}] user clicked");
      if (onNotificationClick != null) {
        onNotificationClick();
      }
    };

    notification.onClickAction = (id) {
      ToolsConfigApp.logger.t(
          "[Notification #${notification.identifier}] user action clicked: $id");
      if (onNotificationClickAction != null) {
        onNotificationClickAction(id);
      }
    };

    // ajout dans le système de notification
    _notificationsList.add(notification);

    // affichage différé
    waitBeforeShow ??= Duration.zero;
    Timer(waitBeforeShow, () async {
      // log
      ToolsConfigApp.logger
          .t("[Notification #${notification.identifier}] call show()");

      // affichage
      await notification.show();

      // gestion du timeout
      if (timeout != null) {
        // programmation d'une fermeture prochaine automatique
        Timer(timeout, () => closeNotification(notification.identifier));
      }
    });

    // retour de l'identifier
    return notification.identifier;
  }

  ///
  /// Recherche d'une notification dans la liste mémoire
  ///
  static LocalNotification? searchNotification(String identifier) {
    try {
      return _notificationsList.firstWhere(
        (notification) => notification.identifier == identifier,
        orElse: () {
          throw Exception("not found");
        },
      );
    } catch (e) {
      return null;
    }
  }

  ///
  /// Cloture d'une notification ouverte
  ///
  static bool closeNotification(String identifier) {
    // Récupération de la notification stockée
    LocalNotification? notification = searchNotification(identifier);
    if (notification == null) {
      // non trouvé
      return false;
    }

    // fermeture de la notification
    notification.close();
    return true;
  }
}
