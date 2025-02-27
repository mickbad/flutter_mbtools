///
/// Services du son dans l'ensemble de l'application
///

// import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;

import '../../config/config.dart';
import '../controllers.dart';

///
/// Mode de contrôle des audios
///
enum SoundFxModeControl {
  // démande de la lecture
  start,

  // arreter la lecture
  stop,

  // pause ou reprise de la lecture
  togglePause,

  // changement du volume
  volume,

  // changement du volume en augmentant progressivement les valeurs
  volumeFadeIn,

  // démarrage de la lecture en augmentant le volume
  startFadeIn,

  // arrêt de la lecture en baissant le volume
  stopFadeOut,
}

///
/// Type de fichier audio (url, fichier local ou asset)
///
enum SoundFxFileType {
  network,
  local,
  asset,
  bytes,
}

///
/// Services du son dans l'ensemble de l'application
///
class SoundFx {
  // générateur de son
  // static final AudioPlayer audioPlayer = AudioPlayer();

  // gestion des préférences
  static final SettingsService prefs = SettingsService();

  // gestion d'un flux audio unique
  static AudioPlayer? audioSingletonPlayer;
  static int audioSingletonPlayerQueueCount =
      0; // indique le nombre d'audio en attente de lecture
  static bool audioSingletonPlayerMustBeStopped =
      false; // indique si le singleton doit être arreter

  ///
  /// Fonction de lecture d'un son dans un asset
  ///
  /// [checkOption] permet de regarder dans les options si le son doit être jouer
  /// [volume] permet d'indiquer un volume au son
  /// [useInternalPackageAssets] à but interne pour utiliser les assets du package
  ///
  static Future<bool> playAsset(
    String assetAudio, {
    bool checkOption = true,
    double? volume,
    bool useInternalPackageAssets = false,
  }) async {
    // asset vide ?
    if (assetAudio.isEmpty) {
      return false;
    }

    // est-on autorisé à lire le son ?
    if (checkOption) {
      bool isSFXEnabled = prefs.get("sound_enabled", false) ?? false;
      if (!isSFXEnabled) {
        return false;
      }
    }

    try {
      // traitement du volume
      volume ??= prefs.get("sound_volume", 1.0) ?? 1.0;
      if (volume < 0.0) {
        volume = 0.0;
      }

      // création du player
      AudioPlayer audioPlayer = AudioPlayer();

      // options
      if (useInternalPackageAssets) {
        audioPlayer.audioCache.prefix = "packages/mbtools/assets/";
      } else {
        audioPlayer.audioCache.prefix = "assets/";
      }

      // on joue un son
      // audioPlayer.setVolume(volume);
      // await audioPlayer.setAsset(assetAudio);
      // audioPlayer.play();
      audioPlayer.play(AssetSource(assetAudio), volume: volume);
      return true;
    } on Exception catch (e1, _) {
      // erreur dans le son
      ToolsConfigApp.logger.e("listen sound from assets error: $e1");
      return true;
    }
  }

  // ---------------------------------------------------------------------------
  // - Fonctions raccourcies des sons
  // ---------------------------------------------------------------------------

  ///
  /// On joue le son de connexion utilisateur
  ///
  static Future<bool> playUserConnected({bool force = false}) async =>
      await playAsset(
        "audio/app/connected-01.mp3",
        checkOption: !force,
        useInternalPackageAssets: true,
      );

  ///
  /// On joue le son de déconnexion utilisateur
  ///
  static Future<bool> playUserDisconnected({bool force = false}) async =>
      await playAsset(
        "audio/app/disconnected-01.mp3",
        checkOption: !force,
        useInternalPackageAssets: true,
      );

  ///
  /// On joue un événement succès (validation d'une commande)
  ///
  static Future<bool> playSuccess({bool force = false}) async =>
      await playAsset(
        "audio/app/winwin.mp3",
        checkOption: !force,
        useInternalPackageAssets: true,
      );

  ///
  /// On joue un événement de téléchargement d'un fichier
  ///
  static Future<bool> playAddItem({bool force = false}) async =>
      await playAsset(
        "audio/app/item-add.mp3",
        checkOption: !force,
        useInternalPackageAssets: true,
      );

  ///
  /// On joue un événement de suppression d'un fichier
  ///
  static Future<bool> playRemoveItem({bool force = false}) async =>
      await playAsset(
        "audio/app/item-delete.mp3",
        checkOption: !force,
        useInternalPackageAssets: true,
      );

  // ---------------------------------------------------------------------------
  // - Fonctions pour jouer en continue les sons et musiques
  // ---------------------------------------------------------------------------

  ///
  /// Attributs intéressants
  ///
  static bool isMusicStopping = false;

  ///
  /// Jouer une musique en continue et avec un contrôle dessus
  ///
  static Future<AudioPlayer?> playMusicControl({
    required SoundFxModeControl control,
    AudioPlayer? player,
    String? assetAudio,
    Uint8List? assetAudioBytes,
    SoundFxFileType assetType = SoundFxFileType.asset,
    bool assetLoop = true,
    int fadeDurationInMilliseconds = 2000,
    double? volume,
    VoidCallback?
        onNaturalFinishPlaying, // callback quand le son est fini naturellement sans boucle
    VoidCallback?
        onEndLoopPlaying, // callback quand on atteint le bout de la musique même en boucle
    bool waitUntilFinishFade = true,
  }) async {
    // traitement des actions
    // final audioAssetName = p.basename(assetAudio ?? player?.audioSource.hashCode.toString() ?? "");
    final audioAssetName =
        p.basename(assetAudio ?? player?.source?.hashCode.toString() ?? "");
    switch (control) {
      case SoundFxModeControl.start:
      case SoundFxModeControl.startFadeIn:
        // définition du volume souhaité par argument ou paramètres ou la valeur par défaut
        volume ??= prefs.get("sound_volume", 1.0) ?? 1.0;
        if (volume < 0.0) {
          volume = 0.0;
        }

        // log
        ToolsConfigApp.logger
            .t("Lecture de l'audio : $audioAssetName : volume = $volume");

        // vérification d'utilisation
        assert(
            assetAudio != null || assetAudioBytes != null, "assetAudio vide");
        if (assetType == SoundFxFileType.bytes) {
          assert(assetAudioBytes != null, "assetAudioBytes vide");
        }

        // création du player
        player = AudioPlayer();

        // Définition du contexte audio (notamment pour Android qui ne peut plus
        // nativement faire 2 flux audios en même temps)
        if (Platform.isAndroid || Platform.isIOS) {
          await player.setAudioContext(AudioContext(
            android: const AudioContextAndroid(
              isSpeakerphoneOn: false,
              audioMode: AndroidAudioMode.normal,
              stayAwake: false,
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.media,
              audioFocus: AndroidAudioFocus.gainTransientMayDuck,
            ),
            iOS: AudioContextIOS(
              // pour mettre en tâche de fond le son même si l'application est minimisé
              // ou focus sur une autre application
              //
              // 1. Vérifier Info.plist
              // Tu as bien ajouté UIBackgroundModes avec audio, ce qui est correct. Assure-toi que cela ressemble à ceci dans ton Info.plist :
              // <key>UIBackgroundModes</key>
              // <array>
              //     <string>audio</string>
              // </array>
              //
              // 2. Activer l’audio en arrière-plan dans Xcode
              // 	•	Ouvre ton projet iOS (ios/Runner.xcworkspace) dans Xcode.
              // 	•	Va dans Signing & Capabilities → + Capability → Ajoute Background Modes.
              // 	•	Coche Audio, AirPlay, and Picture in Picture.
              //
              category: AVAudioSessionCategory.playback,
              options: const {
                AVAudioSessionOptions.mixWithOthers,
                AVAudioSessionOptions.duckOthers,
              },
            ),
          ));
        }

        /* just_audio:
        await player.setUrl(assetAudio!);

        // on joue la musique en boucle
        await player.setLoopMode(LoopMode.all);

        // options
        await player.setSkipSilenceEnabled(true);

        // gestion du volume
        await player.setVolume(volume);

         */

        // démarrage du son
        // player.play();
        switch (assetType) {
          case SoundFxFileType.network:
            await player.play(UrlSource(assetAudio!), volume: volume);
            break;

          case SoundFxFileType.local:
            await player.play(DeviceFileSource(assetAudio!), volume: volume);
            break;

          case SoundFxFileType.asset:
            // suppression du prefix asset/ si ajouté ?
            assetAudio = assetAudio!.replaceAll("assets/", "");
            if (assetAudio.startsWith("/")) {
              assetAudio = assetAudio.substring(1);
            }
            await player.play(AssetSource(assetAudio), volume: volume);
            break;

          case SoundFxFileType.bytes:
            // Lecture des données depuis un tableau de bytes (source d'un
            // fichier audio)
            await player.play(BytesSource(assetAudioBytes!), volume: volume);
            break;
        }

        // gestion de la boucle
        if (assetLoop) {
          await player.setReleaseMode(ReleaseMode.loop);
        }

        // marqueur de fin de lecture si demandé en parallèle
        isMusicStopping = false;

        // gestion du fadein en asynchrone
        if (control == SoundFxModeControl.startFadeIn) {
          if (waitUntilFinishFade) {
            // on attend la fin du son progressif
            await startFadeIn(
                player: player,
                volume: volume,
                fadeDurationInMilliseconds: fadeDurationInMilliseconds);
          } else {
            // on n'attend pas la fin du son progressif
            startFadeIn(
                player: player,
                volume: volume,
                fadeDurationInMilliseconds: fadeDurationInMilliseconds);
          }
        }

        // écoute de la fin de la musique
        player.onPlayerComplete.listen((event) {
          // arrêt de la lecture si pas de boucle
          if (!assetLoop) {
            ToolsConfigApp.logger
                .t("Fin naturel de l'audio (sans boucle) : $audioAssetName");
            if (onNaturalFinishPlaying != null) {
              onNaturalFinishPlaying();
            }
          }

          // callback quand on atteint le bout de la musique
          if (onEndLoopPlaying != null) {
            onEndLoopPlaying();
          }
        });

        // pour android, détection de fin de lecture d'une boucle
        // en effet uniquement sur Android, le onPlayerComplete ne fonctionne pas
        // dès lors que la musique est en boucle
        if (assetLoop && Platform.isAndroid) {
          // configuration
          const millisecondsToCheck = 50;
          const millisecondsToResetTrigger = millisecondsToCheck * 3;
          bool completionTriggered = false;

          // récupération du temps de la musique
          Duration? audioDuration = await player.getDuration();

          // détection de la position
          player.onPositionChanged.listen((Duration p) {
            // si on atteint la fin de la musique avec un delta
            if (audioDuration != null) {
              if (!completionTriggered &&
                  p.inMilliseconds >=
                      audioDuration.inMilliseconds - millisecondsToCheck) {
                // callback quand on atteint le bout de la musique
                ToolsConfigApp.logger
                    .t("Fin naturel de l'audio (Android) : $audioAssetName");
                if (onEndLoopPlaying != null) {
                  onEndLoopPlaying();
                }

                // trigger pour empêcher plusieurs appels pendant le laps de
                // temps du check
                completionTriggered = true;

                // réinitialisation du trigger après un certain temps car
                // lors de la nouvelle boucle il faut être en capacité de relever
                // le drapeau completionTriggered
                Timer(const Duration(milliseconds: millisecondsToResetTrigger),
                    () {
                  completionTriggered = false;
                });
              }
            }
          });
        }

      case SoundFxModeControl.stop:
        ToolsConfigApp.logger.t("Arrêt de l'audio : $audioAssetName");

        // vérification d'utilisation
        assert(player != null, "player vide");

        // arrêt de la lecture
        isMusicStopping = true;
        await player!.stop();
        player.dispose();
        player = null;
        break;

      case SoundFxModeControl.stopFadeOut:
        ToolsConfigApp.logger
            .t("Arrêt de l'audio (fade out) : $audioAssetName");

        // vérification d'utilisation
        assert(player != null, "player vide");

        // arrêt de la lecture
        isMusicStopping = true;

        // Obtenir le volume actuel
        double currentVolume = player!.volume;

        // Définir un délai pour le fondu enchaîné
        final fadeDuration = Duration(milliseconds: fadeDurationInMilliseconds);
        const fadeStepDuration = Duration(milliseconds: 100);
        final steps =
            (fadeDuration.inMilliseconds / fadeStepDuration.inMilliseconds)
                .ceil();

        // Calculer le montant du changement de volume à chaque étape
        final volumeStep = currentVolume / steps;

        // Effectuer le fondu enchaîné
        for (int i = 1; i <= steps; i++) {
          await Future.delayed(fadeStepDuration);

          try {
            final newVolume = currentVolume - (i * volumeStep);
            if (newVolume >= 0.0) {
              await player.setVolume(newVolume);
            }
          } catch (e) {
            ToolsConfigApp.logger.t("Erreur dans le fondu de sortie : $e");
            break;
          }
        }

        // Arrêter la lecture une fois le fondu enchaîné terminé
        await player.stop();
        player.dispose();
        player = null;
        break;

      case SoundFxModeControl.togglePause:
        ToolsConfigApp.logger.t("Pause/Reprise de l'audio : $audioAssetName");

        // vérification d'utilisation
        assert(player != null, "player vide");

        /* just_audio
        if (player!.playing) {
          player.pause();
        } else {
          player.play();
        }
         */
        if (player!.state == PlayerState.playing) {
          await player.pause();
        } else {
          await player.resume();

          // gestion du volume
          if (volume != null && volume >= 0.0) {
            await player.setVolume(volume);
          }
        }
        break;

      case SoundFxModeControl.volume:
        // vérification d'utilisation
        assert(player != null, "player vide");

        // Obtenir le volume actuel
        final newVolume = (volume ?? prefs.get("sound_volume", 1.0) ?? 1.0);
        if (newVolume >= 0.0) {
          // Trop de log visuellement
          // logger.t("Changement du volume de l'audio : $audioAssetName = $newVolume");
          await player!.setVolume(newVolume);
        }
        break;

      case SoundFxModeControl.volumeFadeIn:
        // vérification d'utilisation
        assert(player != null, "player vide");

        // Obtenir le volume actuel
        final newVolume = (volume ?? prefs.get("sound_volume", 1.0) ?? 1.0);
        if (newVolume >= 0.0) {
          // marqueur de fin de lecture si demandé en parallèle
          isMusicStopping = false;

          if (waitUntilFinishFade) {
            // on attend la fin du son progressif
            await startFadeIn(
              player: player!,
              volume: newVolume,
              fadeDurationInMilliseconds: fadeDurationInMilliseconds,
              startFadeZero: false,
            );
          } else {
            // on n'attend pas la fin du son progressif
            startFadeIn(
              player: player!,
              volume: newVolume,
              fadeDurationInMilliseconds: fadeDurationInMilliseconds,
              startFadeZero: false,
            );
          }
        }
        break;
    }

    // retour du player pour traitement ultérieur
    return player;
  }

  ///
  /// Activation du mode fade in du volume de l'audio
  ///
  static Future<void> startFadeIn(
      {required AudioPlayer player,
      required double volume,
      required int fadeDurationInMilliseconds,
      bool startFadeZero = true}) async {
    // check si l'audio est en cours
    // if (!player.playing) {
    if (player.state != PlayerState.playing) {
      return;
    }

    // initialisation
    double startVolumeFade;
    if (startFadeZero) {
      startVolumeFade = 0.0;
      await player.setVolume(startVolumeFade);
    } else {
      // Récupération du volume actuel
      startVolumeFade = player.volume;
    }

    // Définir un délai pour le fondu enchaîné
    const fadeStepDuration = Duration(milliseconds: 100);
    final steps =
        (fadeDurationInMilliseconds / fadeStepDuration.inMilliseconds).ceil();

    // Calculer le montant du changement de volume à chaque étape
    final volumeStep = (volume - startVolumeFade) / steps;

    // Effectuer le fondu enchaîné
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(fadeStepDuration);

      // vérification qu'on n'est pas en train d'éteindre à nouveau
      if (isMusicStopping) {
        break;
      }

      try {
        final newVolume = startVolumeFade + (i * volumeStep);
        if (!isMusicStopping && newVolume >= 0.0) {
          await player.setVolume(newVolume);
        }
      } catch (e) {
        ToolsConfigApp.logger.t("Erreur dans le fondu d'entrée : $e");
        break;
      }
    }
  }

  ///
  /// Procédure de lecture d'un son en mode extrait
  /// On active le son et on arrête en fadeout après [delay] millisecondes
  ///
  static Future<void> playExtractSound({
    required String audioUrl,
    required int delay,
    int fadeDurationInMilliseconds = 2000,
    double? volume,
    AudioPlayer? audioLocalPlayer,
  }) async {
    // le delay doit être minimum de 100 millisecondes
    if (delay < 500) {
      delay = 500;
    }

    // type de son
    SoundFxFileType assetType = SoundFxFileType.asset;
    if (audioUrl.toLowerCase().startsWith("http://") ||
        audioUrl.toLowerCase().startsWith("https://")) {
      assetType = SoundFxFileType.network;
    }

    // nettoyage du lecteur audio en paramètre au cas où on utilise un singleton
    // le garbage collector fera son travail !
    audioLocalPlayer = null;

    // lecture de l'audio
    audioLocalPlayer = await SoundFx.playMusicControl(
      control: SoundFxModeControl.startFadeIn,
      assetAudio: audioUrl,
      assetType: assetType,
      volume: volume,
      assetLoop: false,
    );

    // lecteur streaming du status de lecture (au cas où la musique est plus courte que le délai imparti)
    bool isPlaying = true;
    audioLocalPlayer?.onPlayerComplete.listen((event) {
      ToolsConfigApp.logger.t(
          "Lecture de ${p.basename(audioUrl)} : audio interrompu en deça de $delay millisecondes");
      isPlaying = false;
    });

    // pause et détection d'arrêt du lecteur
    int currentTime = 0;
    while (currentTime < delay) {
      // ma pause :)
      await Future.delayed(const Duration(milliseconds: 100));
      currentTime += 100;

      // détection si l'audio singleton est toujours en cours
      if (!isPlaying || audioSingletonPlayerMustBeStopped) {
        break;
      }
    }

    try {
      // fermeture de l'audio
      if (isPlaying) {
        await SoundFx.playMusicControl(
          control: SoundFxModeControl.stopFadeOut,
          player: audioLocalPlayer,
        );
      }
    } catch (e) {
      ToolsConfigApp.logger.e("Erreur dans le fondu de sortie : $e");
    }

    // fin de lecture de l'audio
    audioLocalPlayer = null;
    audioSingletonPlayerMustBeStopped = false;
  }

  ///
  /// Procédure de lecture d'un son en mode extrait en mode singleton
  /// (une seule écoute à la fois)
  /// On active le son et on arrête en fadeout après [delay] millisecondes
  ///
  static Future<void> playExtractSoundSingleton({
    required String audioUrl,
    required int delay,
    int fadeDurationInMilliseconds = 2000,
    double? volume,
    bool waitEndSingleton = false,
    bool playAfterWaitingSingleton = false,
    int maxQueueCount = 2,
  }) async {
    // vérification d'usage sur le paramètre de queue
    if (maxQueueCount < 1) {
      maxQueueCount = 1;
    }

    // détection si l'audio singleton est déjà en cours
    if (audioSingletonPlayer != null) {
      ToolsConfigApp.logger.w(
          "Lecture de ${p.basename(audioUrl)} interrompue : un précédent audio est en cours de lecture");

      // doit-on attendre la fin de la précédente lecture?
      if (!waitEndSingleton) {
        // non, on retourne la fonction
        return;
      }

      // on augmente le nombre d'audio dans la queue de lecture
      audioSingletonPlayerQueueCount++;

      // attente de la fin de la précédente lecture
      while (true) {
        // ma pause :)
        await Future.delayed(const Duration(milliseconds: 100));
        if (audioSingletonPlayer == null) {
          // fin de la précédente lecture
          // doit-on lancer une nouvelle lecture?
          if (!playAfterWaitingSingleton ||
              audioSingletonPlayerQueueCount >= maxQueueCount) {
            // non, on retourne la fonction sans lire la nouvelle lecture
            audioSingletonPlayerQueueCount =
                max(0, audioSingletonPlayerQueueCount - 1);
            return;
          }

          // on diminue la queue de lecture car on en fait une nouvelle
          audioSingletonPlayerQueueCount =
              max(0, audioSingletonPlayerQueueCount - 1);
          break;
        }
      }
      // return;
    }

    // initialisation du singleton
    audioSingletonPlayer = AudioPlayer();

    // démarrage du son par singleton
    await playExtractSound(
      audioUrl: audioUrl,
      delay: delay,
      fadeDurationInMilliseconds: fadeDurationInMilliseconds,
      volume: volume,
      audioLocalPlayer: audioSingletonPlayer,
    );

    // fermeture du singleton
    audioSingletonPlayer = null;
  }

  ///
  /// Procédure d'arrêt d'un son en mode extrait en mode singleton
  /// utile lors d'une fin d'écran
  ///
  static Future stopExtractSoundSingleton() async {
    // arret du son par singleton
    if (audioSingletonPlayer != null) {
      // log
      ToolsConfigApp.logger.t("Arrêt de toutes les demandes audios singleton");
      audioSingletonPlayerMustBeStopped = true;
    }
  }
}
