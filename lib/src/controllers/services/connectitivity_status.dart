///
/// Notification du status de la connexion au service internet
///
/// doc : https://medium.com/@shreebhagwat94/handle-internet-connectivity-in-flutter-with-riverpod-bbde21c187dc
///

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../config/config.dart';

///
/// Enumération des status
///
enum ConnectivityStatus { notDetermined, isConnected, isDisconnected }

///
/// Classe de recherche
///
class ConnectivityStatusManager extends ChangeNotifier {
  ///
  /// paramètres de connexion
  ///
  ConnectivityStatus? lastResult;
  ConnectivityStatus? newState;

  ///
  /// Appel de la fonction lors de la reconnexion
  ///
  final Future<void> Function()? onRetrieveConnexion;

  ///
  /// Appel de la fonction lors de la reconnexion
  ///
  final Future<void> Function()? onLostConnexion;

  ///
  /// Constructeur
  ///
  ConnectivityStatusManager({
    this.onRetrieveConnexion,
    this.onLostConnexion,
  }) {
    lastResult = ConnectivityStatus.notDetermined;

    // souscription au statut de la connexion
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      if (result.isEmpty || result.contains(ConnectivityResult.none)) {
        newState = ConnectivityStatus.isDisconnected;
        if (newState != lastResult) {
          // info
          ToolsConfigApp.logger.w("Il n'y a plus de connexion Internet");

          // callback
          if (onLostConnexion != null) {
            await onLostConnexion!();
          }
        }
      } else if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet) ||
          result.contains(ConnectivityResult.bluetooth) ||
          result.contains(ConnectivityResult.vpn) ||
          result.contains(ConnectivityResult.other)) {
        newState = ConnectivityStatus.isConnected;
        if (newState != lastResult) {
          // info
          ToolsConfigApp.logger.w("La connection à internet a été retrouvée");

          // callback
          if (onRetrieveConnexion != null) {
            await onRetrieveConnexion!();
          }
        }
      }

      // information du status
      if (newState != lastResult) {
        lastResult = newState;
      }
    });
  }
}
