import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/config.dart';

enum RequestType { get, post, put, delete }

// Gestion du cache des requêtes
Map<String, dynamic> _cacheResponse = {};
Map<String, double> _cacheResponseDatetime = {};

/// Fonction d'appel à l'api
Future<Post> fetchPost(
  RequestType type,
  String route, {
  Map<String, String>? options,
  Map<String, String>? postBody,
  Map<String, String>? headers,
  bool cacheResults = true,
  bool resetCache = false,
  bool isApiKeyHeader = true,
}) async {
  // récupération de l'adresse de l'api customisé ou pas
  // bool isGzipResponse = false;

  // variables
  late http.Response response;
  bool isCachedResponse = false;
  String _completeUrl = "${ToolsConfigApp.appApiURL}$route";

  // gestion de la clef automatique dans querystring si demandé
  if (!isApiKeyHeader) {
    // création si nécessaire
    options ??= {};

    // ajout de l'api key
    options["api_key"] = ToolsConfigApp.appApiKey;
  }

  // options de la requête depuis l'utilisateur
  if (options != null) {
    _completeUrl += generateStringUrlOptions(options);
  }

  // gestion du POST
  postBody ??= {};
  Map<String, String> localHeaders = {};
  localHeaders["user-agent"] = await getHeaderUserAgent();
  localHeaders["Access-Control-Allow-Origin"] = "*";
  localHeaders["Accept"] = "*/*";

  if (isApiKeyHeader) {
    localHeaders["x-api-key"] = ToolsConfigApp.appApiKey;
  }

  if (headers != null && headers.isNotEmpty) {
    localHeaders.addAll(headers);
  }

  // Gestion du cache
  if (!resetCache &&
      cacheResults &&
      _cacheResponse.containsKey(_completeUrl) &&
      _cacheResponseDatetime.containsKey(_completeUrl)) {
    // comparaison du temps actuel avec le max cachable de l'url
    double compare = 0.0;
    if (_cacheResponseDatetime[_completeUrl] != null) {
      compare = _cacheResponseDatetime[_completeUrl]! -
          DateTime.now().millisecondsSinceEpoch / 1000.0;
    }

    if (_cacheResponseDatetime.containsKey(_completeUrl) && compare >= 0.0) {
      // utilisation du cache
      if (kDebugMode) {
        ToolsConfigApp.logger
            .t("Using cache for $_completeUrl ($compare seconds left)");
      } else {
        ToolsConfigApp.logger
            .t("Using cache for $route ($compare seconds left)");
      }
      response = _cacheResponse[_completeUrl];
      isCachedResponse = true;
    }
  }

  // appel à l'api
  if (!isCachedResponse) {
    // fabrication de l'url URI
    Uri completeUrl = Uri.parse(_completeUrl);

    try {
      switch (type) {
        case RequestType.get:
          response = await http.get(completeUrl, headers: localHeaders);
          break;
        case RequestType.post:
          response =
              await http.post(completeUrl, body: postBody, headers: localHeaders);
          break;
        case RequestType.put:
          response =
              await http.put(completeUrl, body: postBody, headers: localHeaders);
          break;
        case RequestType.delete:
          response = await http.delete(completeUrl, headers: localHeaders);
          break;
      }

      // gestion du stockage dans le cache
      if (cacheResults) {
        if (kDebugMode) {
          ToolsConfigApp.logger.t(
              "Set cache for $completeUrl (${response.contentLength} octets)");
        } else {
          ToolsConfigApp.logger
              .t("Set cache for $route (${response.contentLength} octets)");
        }

        _cacheResponse[_completeUrl] = response;
        _cacheResponseDatetime[_completeUrl] =
            DateTime.now().millisecondsSinceEpoch / 1000.0 +
                ToolsConfigApp.appApiMaxDurationCacheSeconds.abs();
      }
    } on Exception catch (e) {
      return Post.fromJson({"error": e.toString()}, 599);
    }
  }

  // retour des données
  try {
    // décompression des données si nécessaire
    String responseQuery;
    /*
    if (isGzipResponse) {
      // décompression
      final data = GZipCodec().decode(response.bodyBytes);
      // affectation
      responseQuery = utf8.decode(data, allowMalformed: true);
    }
    else*/
    // récupération des données sans compression
    responseQuery = response.body;

    // lecture des données
    return Post.fromJson(json.decode(responseQuery), response.statusCode);
  } catch (e) {
    return Post.fromJson({"error": e.toString()}, 599);
  }
}

String generateStringUrlOptions(Map<String, String> options) {
  String finalString = "";

  options.forEach((key, value) {
    finalString += '&$key=$value';
  });

  if (finalString.isEmpty) {
    return "";
  }

  return "?${finalString.substring(1)}";
}

/// récupération de la version de l'application
Future<String> getHeaderUserAgent() async {
  if (kIsWeb) {
    // retour d'un user agent pour le navigateur web
    return "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.142.86 Safari/537.36";
  }

  // Nom de l'os
  final osName = ToolsConfigApp.getPlatformName.toUpperCase();

  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "${packageInfo.appName.toUpperCase()}/$osName/${packageInfo.version}";
  } on Exception catch (_) {
    return "${ToolsConfigApp.appName}/$osName/Apps".toUpperCase();
  }
}

// -----------------------------------------------------------------------------
// - Outils des réponses
// -----------------------------------------------------------------------------
/// Objet de gestion des résultats api
class Post {
  final String name;
  final double time;
  final Map<String, dynamic> body;
  final int status;

  Post({
    required this.name,
    required this.time,
    required this.body,
    required this.status,
  });

  factory Post.fromJson(Map<String, dynamic> body, int status) {
    return Post(
      name: body["name"] ?? "",
      time: body["time"] ?? 0.0,
      status: status,
      body: body,
    );
  }

  // Redéfinir la méthode `toString`
  @override
  String toString() {
    return 'Post { name: "$name", time: $time, status: $status, body: $body }';
  }
}
