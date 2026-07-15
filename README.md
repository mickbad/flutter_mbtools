## mbtools for Flutter

wait for documentation...

### Usage

Usage in flutter

```yaml
  # librairie ricochets.dev
  mbtools:
    git:
      url: https://github.com/mickbad/flutter_mbtools.git
      ref: [VERSION]
```


### navigator key integration

First class app with *MaterialApp* and fix navigatorKey (auto context in toast message, for example)

```dart
import 'package:mbtools/mbtools.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      navigatorKey: ToolsConfigApp.appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainApp(),
    );
  }
}
```

### auto updater sample

in *main()* function

```dart
  AppUpdateChecker.init(
    navigatorKey: ToolsConfigApp.appNavigatorKey,
    jsonUrl: "https://raw.githubusercontent.com/mickbad/flutter_mbtools/refs/heads/main/flutter_mbtools_updater.json",
    beta: ToolsConfigApp.preferences.get("updates_beta_enabled", false) as bool,
    autoStartCheck: ToolsConfigApp.preferences.get("updates_auto_enabled", false) as bool,
    lang: "en",

    // on télécharge et on exécute le fichier de mise à jour
    onJsonDownloadResults: (results) async {
      ToolsConfigApp.logger.i("Update found in \"${results.url}\"");

      // demande confirmation de la mise à jour
      final confirm = await ToolsHelpers.showConfirmDialog(
        message: 'Update downloaded, execute?\n\nThe application will be closed while the update is installed.',
        validTextLabel: "Launch update",
        cancelTextLabel: "Cancel",
      );
      if (!confirm) return;

      // procédure d'installation
      try {
        if (Platform.isLinux) {
          // demande de sauvegarde du fichier téléchargé
          await results.askToSaveDestination();
        }

        else {
          // plateforme pouvant exécuter un fichier d'installation
          // exécution du fichier de mise à jour
          await results.saveAndExecute(
            quitSoftware: true, // default: true
            delayQuit: const Duration(milliseconds: 1520), // default: 2 seconds
          );
        }

      } catch (e) {
        ToolsConfigApp.logger.e("Updater Error: ${e.toString()}");

        try {
          ToolsHelpers.showSnackbarContext(
            "Updater Error: ${e.toString()}",
            success: false,
          );
        } catch(_) {}
      }
    }
  );
``` 
