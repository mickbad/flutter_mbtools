import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mbtools/mbtools.dart';
import 'package:mbtools_display/mytheme.dart';

const appName = "mbTools Sample";

Future main() async {
  // Configurations de l'application
  WidgetsFlutterBinding.ensureInitialized();

  ///
  /// Couleurs
  ///
  ToolsConfigApp.appPrimaryColor = const Color(0xFFC5DBDE);
  ToolsConfigApp.appSecondaryColor = const Color(0xFF5B8AD2);

  ///
  /// Configurations init
  ///
  ToolsConfigApp.appName = appName;
  await ToolsConfigApp.initSettings();

  // ajustements supplémentaires
  ToolsConfigApp.logger.level = LogLevel.trace;

  ///
  /// Configuration des notifications desktop
  ///
  await DesktopNotifications.initNotificationSystem();
  Future.delayed(const Duration(seconds: 10), () async {
    // affichage d'une notification système
    ToolsConfigApp.logger.i("User show DesktopNotifications!");

    if (ToolsConfigApp.isDesktopApplication) {
      DesktopNotifications.displayNotification(
        title: appName,
        body: "It's Ok for me!",
        onNotificationClick: () {
          ToolsConfigApp.logger.i("User click on DesktopNotifications!");
        },
      );
    } else {
      mbNotifications t = mbNotifications("mipmap/ic_launcher");
      await t.sendBasicMessage(appName, "It's Ok for me!", "payload");
    }
  });

  ///
  /// Configuration de la fenêtre
  ///
  await ToolsConfigApp.configureDesktopWindow(
    appName: appName,
    setIconAppBadgeText: "0",
  );

  // démarrage de l'application
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /*
     -> Méthode normale

    return MaterialApp(
      navigatorKey: ToolsConfigApp.appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainApp(),
    );
    */

    /*
     -> Méthode avec riverpod pour gérer le thème
    */
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
          title: appName,
          home: const MainApp(),
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

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  // controleur de lien pour les menus
  final BackgroundOpenLinkController backgroundOpenLinkController =
      BackgroundOpenLinkController(
    zoomFactor: 12.0,
    duration: 300,
  );

  // flag
  bool animateBackground = true;
  String currentThemeName = "";

  // controleurs
  final CustomModalSheetController modalGeneralController =
      CustomModalSheetController();
  final CustomModalSheetController modalSheetController =
      CustomModalSheetController();
  final CustomIconButtonController customIconButtonController =
      CustomIconButtonController();
  TextEditingController txtButtonController = TextEditingController();
  String txtButtonContent = "";

  @override
  void initState() {
    super.initState();
    currentThemeName = ToolsThemeApp.currentThemeName;
  }

  @override
  void dispose() {
    txtButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // dimensions
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final dialogGeneralWidth = width * .85;
    const dialogGeneralHeightActionButtons = 40.0;
    const dialogGeneralBorderRadius = 20.0;

    // Affichage du menu de la page
    Widget menuDisplayWidget = ExtendedContainerContent(
      width: width,
      height: height,
      imageAnimate: animateBackground,
      imageAsset: "assets/images/foret-fees-nuit.png",
      imageGyroscopeAnimate: false,
      contentBackgroundColor: Colors.black.withValues(alpha: 0.3),
      title: appName,
      titleStyle: TextStyle(
        color: ToolsConfigApp.appWhiteColor,
        fontSize: 20.5,
      ),
      subtitle: "Demonstration",
      subtitleStyle: TextStyle(
        color: ToolsConfigApp.appPrimaryColor.lighten(0.2),
        fontSize: 15.5,
      ),
      legend: ToolsConfigApp.appCopyrightName,
      bottomActions: <Widget>[
        // affichage du popup bottom sheet
        IconButton(
          onPressed: () {
            SoundFx.playUserDisconnected();
            CustomSheetModal.bottomSheet(
              context,
              controller: modalSheetController,
              title: "Modal window",
              titleStyle: TextStyle(color: ToolsConfigApp.appPrimaryColor),
              widthFactor: 0.85,
              childPadding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              titleWidgetLeading: [
                GestureDetector(
                  onTap: () {
                    modalSheetController.closeDialog();
                  },
                  child: Icon(
                    Icons.roundabout_left,
                    color: ToolsConfigApp.appYellowColor,
                  ),
                ),
              ],
              titleWidgetTrailing: [
                const Text("1", style: TextStyle(color: Colors.white)),
                const Text("2", style: TextStyle(color: Colors.white)),
                Icon(
                  Icons.arrow_circle_left_outlined,
                  color: ToolsConfigApp.appInvertedColor,
                ),
                const Text("3", style: TextStyle(color: Colors.white)),
              ],
            );
          },
          icon: Icon(
            Icons.arrow_circle_up_outlined,
            color: ToolsConfigApp.appInvertedColor,
          ),
        ),

        // affichage du popup general
        IconButton(
          onPressed: () {
            SoundFx.playUserDisconnected();
            CustomSheetModal.generalDialog(
              context,
              controller: modalGeneralController,
              alignmentBox: Alignment.topRight,
              isDismissible: true,
              title: "Modal window",
              titleStyle: TextStyle(color: ToolsConfigApp.appPrimaryColor),
              backgroundColorTitleBox: ToolsConfigApp.appBlueColor.darken(),
              // widthXFactor: 0.85,
              width: dialogGeneralWidth,
              height: 400,
              borderRadiusModal:
                  BorderRadius.circular(dialogGeneralBorderRadius),
              backgroundColorModal: ToolsConfigApp.appBlueColor.lighten(0.01),
              childPadding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              titleWidgetLeading: [
                GestureDetector(
                  onTap: () {
                    modalGeneralController.closeDialog();
                  },
                  child: Icon(
                    Icons.roundabout_left,
                    color: ToolsConfigApp.appYellowColor,
                  ),
                ),
              ],
              titleWidgetTrailing: [
                const Text("1", style: TextStyle(color: Colors.white)),
                const Text("2", style: TextStyle(color: Colors.white)),
                Icon(
                  Icons.arrow_circle_left_outlined,
                  color: ToolsConfigApp.appInvertedColor,
                ),
                const Text("3", style: TextStyle(color: Colors.white)),
              ],
              heightActionButtons: dialogGeneralHeightActionButtons,
              actionButtons: [
                // Bouton J'accepte
                GestureDetector(
                  onTap: () {
                    debugPrint("J'accepte");
                    ToolsHelpers.showSnackbarContext(
                      context,
                      "J'accepte",
                      isDismissible: true,
                      blockBackgroundInteraction: true,
                      onClose: () => Navigator.pop(context),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: ToolsConfigApp.appGreenColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(dialogGeneralBorderRadius),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "J'ACCEPTE",
                        style: TextStyle(
                          color: ToolsConfigApp.appInvertedColor,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ),

                // une icône
                IconButton(
                  onPressed: () {
                    customIconButtonController.activateButton();
                  },
                  icon: const Icon(Icons.add_reaction, size: 20),
                ),

                // Bouton Je refuse
                GestureDetector(
                  onTap: () {
                    debugPrint("Je refuse");
                    ToolsHelpers.showSnackbarContext(
                      context,
                      "Je refuse",
                      success: false,
                      isDismissible: false,
                      blockBackgroundInteraction: true,
                      onClose: () => Navigator.pop(context),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: ToolsConfigApp.appAlertColor,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(dialogGeneralBorderRadius),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "JE REFUSE",
                        style: TextStyle(
                          color: ToolsConfigApp.appInvertedColor,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // contenu
              child: Column(
                children: [
                  const Text(
                    "Hello World",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Code Coupon
                  if (txtButtonContent.isNotEmpty) ...[
                    Text(
                      txtButtonContent,
                      style: const TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // bouton d'accueil
                  CustomIconButton(
                    controller: customIconButtonController,
                    icon: Icon(
                      Icons.check,
                      color: ToolsConfigApp.appWhiteColor,
                    ),
                    showGlowBorder: true,
                    onActionButton: () async {
                      ToolsHelpers.showSnackbarContext(
                          context, "Welcome here !");
                      setState(() {
                        txtButtonContent = "CLICKED !";
                      });
                    },
                    text: "Click me, please!",
                  ),
                  const SizedBox(height: 20),

                  // bouton de zone de texte
                  CustomIconButton(
                    height: 45,
                    icon: Icon(
                      Icons.question_answer_rounded,
                      color: ToolsConfigApp.appPrimaryColor,
                    ),
                    iconBackgroundColor: ToolsConfigApp.appGreenColor,
                    onActionButton: () async {
                      final String text = txtButtonController.text;
                      ToolsHelpers.showSnackbarContext(
                          context, "You write: $text!");
                    },
                    textFieldEnabled: true,
                    textFieldController: txtButtonController,
                    textFieldHintText: "Saisir un texte",
                    textFieldPadding: const EdgeInsets.only(
                      left: 10.0,
                      top: 0.0,
                    ),
                    textFieldStyle: TextStyle(
                      color: ToolsConfigApp.appGreenColor,
                    ),
                    textFieldOnChanged: (value) {
                      // traitement du texte
                      String text = ToolsHelpers.textOnlyAlphanumeric(
                        value,
                        keepSpace: false,
                        uppercase: true,
                      );
                      setState(() {
                        txtButtonContent = text;
                      });

                      // retour pour traitement
                      return text;
                    },
                    textFieldOnBeforeSubmitted: (value) => ToolsConfigApp.logger
                        .t("Validation du champ coupon \"$value\" pour l'utilisateur"),
                    onActionButtonValidator: () =>
                        txtButtonController.text.isNotEmpty,
                  ),
                ],
              ),
            );
          },
          icon: Icon(
            Icons.arrow_circle_up_outlined,
            color: ToolsConfigApp.appYellowColor,
          ),
        ),
      ],
      topActions: <Widget>[
        IconButton(
            onPressed: () {
              setState(() {
                animateBackground = !animateBackground;
              });
              SoundFx.playRemoveItem();

              // notification
              /*
              DesktopNotifications.displayNotification(
                title: "Ave",
                body: "Activation de l'animation : $animateBackground",
                waitBeforeShow: const Duration(seconds: 5),
                timeout: const Duration(seconds: 5),
                actions: ["Revert"],
                onNotificationClickAction: (value) => setState(() {
                  animateBackground = !animateBackground;
                }),
              );
              */
            },
            icon: Icon(
              (animateBackground) ? Icons.pause : Icons.play_arrow,
              color: ToolsConfigApp.appInvertedColor,
            )),
      ],
      controllerOpenLink: backgroundOpenLinkController,
      menus: [
        MenuButtonItem(
          enabled: true,
          heightMenus: 60,
          imageAsset: "assets/images/foret-fees-nuit.png",
          title: "mon titre 1",
          titleStyle: TextStyle(color: ToolsConfigApp.appWhiteColor),
          imageColorBend: Colors.yellowAccent,
          trailing: Icon(
            Icons.home,
            color: ToolsConfigApp.appInvertedColor,
          ),
          leading: Icon(
            Icons.arrow_forward,
            color: ToolsConfigApp.appInvertedColor,
          ),
          onTap: () {
            SoundFx.playUserConnected();
          },
        ),
        MenuButtonItem(
          enabled: true,
          heightMenus: 60,
          imageAsset: "assets/images/foret-fees-nuit.png",
          title: "mon titre 2",
          titleStyle: TextStyle(color: ToolsConfigApp.appWhiteColor),
          imageColorBend: Colors.red,
          trailing: Icon(
            Icons.home,
            color: ToolsConfigApp.appInvertedColor,
          ),
          leading: Icon(
            Icons.arrow_forward,
            color: ToolsConfigApp.appInvertedColor,
          ),
          onTap: () {
            SoundFx.playAddItem();
            final int i = Random().nextInt(100);
            ToolsConfigApp.setDesktopIconAppBadge(text: "$i");
          },
        ),

        // Changement de thème
        MenuButtonItem(
          enabled: true,
          heightMenus: 60,
          imageAsset: "assets/images/foret-fees-nuit.png",
          title: "Thème : $currentThemeName",
          titleStyle: TextStyle(color: ToolsConfigApp.appWhiteColor),
          imageColorBend: ToolsConfigApp.appPrimaryColor.withValues(alpha: 0.3),
          trailing: Icon(
            Icons.colorize,
            color: ToolsConfigApp.appPrimaryColor,
          ),
          leading: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: ToolsConfigApp.appPrimaryColor,
              border: Border.all(
                color: ToolsConfigApp.appSecondaryColor, // Couleur du contour
                width: 2, // Épaisseur du contour
              ),
              boxShadow: [
                BoxShadow(
                  color: ToolsConfigApp.appThirdColor.withValues(alpha: .5),
                  spreadRadius: 7,
                  blurRadius: 2,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          onTap: () {
            // récupération des thèmes disponibles
            final themesAvailable = ToolsThemeApp.primaryColorsListAvailable;

            // Générer un index aléatoire
            Random random = Random();
            int randomIndex = random.nextInt(themesAvailable.length);

            // Récupérer l'élément aléatoire
            String randomTheme = themesAvailable[randomIndex]["desc"];
            ToolsConfigApp.logger.i("Change theme to: $randomTheme");

            // affectation du thème
            ToolsThemeAppRiverpod currentTheme =
                ref.read(appThemeProvider.notifier);
            currentTheme.setTheme(randomTheme);
            setState(() {
              currentThemeName = randomTheme;
            });
          },
        ),
      ],
    );

    // affichage de la fenêtre avec l'observeur de dimensions
    return ToolsConfigApp.desktopWindowSizeObserver(
      app: Scaffold(
        // pour gérer la fenêtre sans bord
        body: ToolsConfigApp.desktopWindowShowAppCaptionIcons(
          body: menuDisplayWidget,
        ),
      ),
      onChangeWindowSize: (newSize) {
        ToolsConfigApp.logger.t("Nouvelle taille de fenêtre : $newSize");
      },
    );
  }
}
