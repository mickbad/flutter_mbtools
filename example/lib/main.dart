import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mbtools/mbtools.dart';

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
  // await DesktopNotifications.initNotificationSystem();

  ///
  /// Configuration de la fenêtre
  ///
  await ToolsConfigApp.configureDesktopWindow(
    appName: appName,
    setIconAppBadgeText: "0",
  );

  // démarrage de l'application
  runApp(const MyApp());
}

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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // controleur de lien pour les menus
  final BackgroundOpenLinkController backgroundOpenLinkController =
      BackgroundOpenLinkController(
    zoomFactor: 12.0,
    duration: 300,
  );

  // flag
  bool animateBackground = true;

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
        color: ToolsConfigApp.appGreenColor,
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
      ],
    );

    // affichage de la fenêtre avec l'observeur de dimensions
    return ToolsConfigApp.desktopWindowSizeObserver(
      app: Scaffold(
        body: menuDisplayWidget,
      ),
      onChangeWindowSize: (newSize) {
        ToolsConfigApp.logger.t("Nouvelle taille de fenêtre : $newSize");
      },
    );
  }
}
