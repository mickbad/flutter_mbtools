// media_metadata_manager.dart
//
// Lecture / écriture de métadonnées pour fichiers MP3 (tags ID3v2.3) et
// MP4/M4A (atomes "ilst" de style iTunes), en Dart pur (aucune dépendance
// externe, uniquement dart:io, dart:convert, dart:typed_data).
//
// Champs gérés : titre, auteur, album, numéro de piste, pochette (MP3
// uniquement), commentaire, genre.
//
// Principe d'écriture : `writeTags` relit d'abord l'intégralité des tags
// existants du fichier, fusionne dedans uniquement les champs non-null
// passés en paramètre, puis reconstruit et sauvegarde le bloc de
// métadonnées complet (les frames/atomes non modifiés sont recopiés tels
// quels grâce à la fusion).
//
// Exemple d'utilisation :
//
//   final tags = await MediaMetadataManager.readTags('chanson.mp3');
//   print(tags.title);
//
//   await MediaMetadataManager.writeTags(
//     'chanson.mp3',
//     const MediaTags(title: 'Nouveau titre', genre: 'Jazz'),
//   );
//
// LIMITES CONNUES (implémentation volontairement pragmatique) :
//  - MP3 : écrit uniquement en ID3v2.3 (le plus répandu). La lecture gère
//    ID3v2.3 et ID3v2.4 pour les frames texte/APIC/COMM les plus courantes.
//    Pas de support de l'unsynchronisation ni des en-têtes étendus.
//  - MP4 : suppose un fichier "classique" (un seul atome moov, pas de
//    fragmentation moof/mdat). Les tables de décalage stco/co64 sont
//    corrigées automatiquement si la taille de moov change et que moov
//    précède mdat dans le fichier (cas standard). Les tailles d'atomes en
//    64 bits pour moov/udta/meta ne sont pas gérées (rarissime en pratique).
//  - Le genre MP4 sous forme d'index ID3v1 ("gnre") n'est pas décodé en
//    lecture ; seul le format texte libre ("©gen"), largement majoritaire
//    aujourd'hui, est supporté.
//
// Pour un besoin de robustesse maximale (tous formats, tous cas limites),
// préférez une bibliothèque native éprouvée (ex. TagLib via FFI) plutôt
// que ce parseur "maison".

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Valeurs à appliquer lors d'une écriture. Un champ à `null` signifie
/// "ne pas modifier" : la valeur existante dans le fichier est conservée.
class MediaTags {
  final String? title;
  final String? artist;
  final String? album;
  final int? trackNumber;

  /// Image de pochette, uniquement prise en compte pour les fichiers MP3.
  final Uint8List? coverImage;

  /// Type MIME de [coverImage] (ex. 'image/jpeg'). Deviné automatiquement
  /// si laissé à `null`.
  final String? coverMimeType;

  final String? comment;
  final String? genre;

  const MediaTags({
    this.title,
    this.artist,
    this.album,
    this.trackNumber,
    this.coverImage,
    this.coverMimeType,
    this.comment,
    this.genre,
  });

  /// Construit un [MediaTags] à partir de la Map brute renvoyée par un
  /// codec interne ([Id3v2Codec.read] / [Mp4Codec.read]).
  factory MediaTags._fromMap(Map<String, dynamic> m) {
    return MediaTags(
      title: m[MetaKeys.title] as String?,
      artist: m[MetaKeys.artist] as String?,
      album: m[MetaKeys.album] as String?,
      trackNumber: m[MetaKeys.track] as int?,
      coverImage: m[MetaKeys.cover] as Uint8List?,
      coverMimeType: m[MetaKeys.coverMime] as String?,
      comment: m[MetaKeys.comment] as String?,
      genre: m[MetaKeys.genre] as String?,
    );
  }

  /// Reconstruit la Map brute attendue par les codecs internes
  /// ([Id3v2Codec.write] / [Mp4Codec.write]). Seuls les champs non-null
  /// sont inclus.
  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{};
    if (title != null) m[MetaKeys.title] = title;
    if (artist != null) m[MetaKeys.artist] = artist;
    if (album != null) m[MetaKeys.album] = album;
    if (trackNumber != null) m[MetaKeys.track] = trackNumber;
    if (comment != null) m[MetaKeys.comment] = comment;
    if (genre != null) m[MetaKeys.genre] = genre;
    if (coverImage != null) {
      m[MetaKeys.cover] = coverImage;
      m[MetaKeys.coverMime] = coverMimeType;
    }
    return m;
  }

  /// Retourne un nouveau [MediaTags] où chaque champ non-null de
  /// [changes] remplace le champ correspondant de `this`, les champs
  /// laissés à `null` dans [changes] étant conservés depuis `this`.
  /// C'est cette méthode qui implémente la fusion "existant + modifs".
  MediaTags mergeWith(MediaTags changes) {
    final newCover = changes.coverImage ?? coverImage;
    final newCoverMime = changes.coverImage != null
        ? (changes.coverMimeType ?? _guessMime(changes.coverImage!))
        : coverMimeType;
    return MediaTags(
      title: changes.title ?? title,
      artist: changes.artist ?? artist,
      album: changes.album ?? album,
      trackNumber: changes.trackNumber ?? trackNumber,
      coverImage: newCover,
      coverMimeType: newCoverMime,
      comment: changes.comment ?? comment,
      genre: changes.genre ?? genre,
    );
  }

  static String _guessMime(Uint8List data) {
    if (data.length >= 8 &&
        data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47) {
      return 'image/png';
    }
    return 'image/jpeg';
  }
}

/// Clés utilisées en interne pour transporter les tags entre les codecs
/// bas niveau ([Id3v2Codec], [Mp4Codec]) et l'objet [MediaTags].
class MetaKeys {
  static const String title = 'title';
  static const String artist = 'artist';
  static const String album = 'album';
  static const String track = 'track'; // int
  static const String cover = 'cover'; // Uint8List (MP3 uniquement)
  static const String coverMime = 'coverMime'; // String
  static const String comment = 'comment';
  static const String genre = 'genre';
}

/// Point d'entrée principal : détecte le format via l'extension du
/// fichier et délègue au lecteur/écrivain approprié.
class MediaMetadataManager {
  /// Lit les tags du fichier et les retourne sous forme de [MediaTags]
  /// (un champ à `null` signifie simplement "absent du fichier").
  static Future<MediaTags> readTags(String path) async {
    final ext = _extensionOf(path);
    final bytes = await File(path).readAsBytes();
    if (ext == 'mp3') {
      return MediaTags._fromMap(Id3v2Codec.read(bytes));
    } else if (ext == 'mp4' || ext == 'm4a' || ext == 'm4v') {
      return MediaTags._fromMap(Mp4Codec.read(bytes));
    }
    throw UnsupportedError('Format non supporté : .$ext');
  }

  /// Relit les tags existants, fusionne [changes] par-dessus (via
  /// [MediaTags.mergeWith]) et sauvegarde le résultat dans le fichier.
  static Future<void> writeTags(String path, MediaTags changes) async {
    final ext = _extensionOf(path);
    final file = File(path);
    final original = await file.readAsBytes();

    if (ext == 'mp3') {
      final existing = MediaTags._fromMap(Id3v2Codec.read(original));
      final merged = existing.mergeWith(changes);
      final updated = Id3v2Codec.write(original, merged.toMap());
      await file.writeAsBytes(updated, flush: true);
    } else if (ext == 'mp4' || ext == 'm4a' || ext == 'm4v') {
      final existing = MediaTags._fromMap(Mp4Codec.read(original));
      final merged = existing.mergeWith(changes);
      final updated = Mp4Codec.write(original, merged.toMap());
      await file.writeAsBytes(updated, flush: true);
    } else {
      throw UnsupportedError('Format non supporté : .$ext');
    }
  }

  static String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '';
    return path.substring(dot + 1).toLowerCase();
  }
}

// ---------------------------------------------------------------------
// Fonctions binaires communes
// ---------------------------------------------------------------------

int _synchsafeToInt(List<int> b) {
  return (b[0] << 21) | (b[1] << 14) | (b[2] << 7) | b[3];
}

List<int> _intToSynchsafe(int v) {
  return [(v >> 21) & 0x7F, (v >> 14) & 0x7F, (v >> 7) & 0x7F, v & 0x7F];
}

int _beToInt(List<int> b) {
  int v = 0;
  for (final x in b) {
    v = (v << 8) | x;
  }
  return v;
}

List<int> _intToBe(int v, int len) {
  final out = List<int>.filled(len, 0);
  for (int i = len - 1; i >= 0; i--) {
    out[i] = v & 0xFF;
    v >>= 8;
  }
  return out;
}

// =======================================================================
// MP3 — ID3v2
// =======================================================================

class Id3v2Codec {
  static const Map<String, String> _textFrameMap = {
    'TIT2': MetaKeys.title,
    'TPE1': MetaKeys.artist,
    'TALB': MetaKeys.album,
    'TRCK': MetaKeys.track,
    'TCON': MetaKeys.genre,
  };

  /// Lit les frames d'un tag ID3v2 en tête de fichier et les retourne
  /// sous forme de Map. Retourne une Map vide si aucun tag ID3v2 n'est
  /// présent.
  static Map<String, dynamic> read(Uint8List bytes) {
    final result = <String, dynamic>{};
    if (bytes.length < 10 ||
        bytes[0] != 0x49 || // 'I'
        bytes[1] != 0x44 || // 'D'
        bytes[2] != 0x33) {
      // 'D3' -> pas de tag ID3v2 en tête de fichier
      return result;
    }

    final majorVersion = bytes[3];
    final tagSize = _synchsafeToInt(bytes.sublist(6, 10));
    final end = 10 + tagSize;
    int pos = 10;

    while (pos + 10 <= end && pos + 10 <= bytes.length) {
      final idBytes = bytes.sublist(pos, pos + 4);
      if (idBytes[0] == 0) break; // zone de padding atteinte
      final frameId = latin1.decode(idBytes);

      final sizeBytes = bytes.sublist(pos + 4, pos + 8);
      final frameSize = majorVersion >= 4
          ? _synchsafeToInt(sizeBytes)
          : _beToInt(sizeBytes);
      pos += 10; // en-tête de frame : id(4) + taille(4) + flags(2)

      if (frameSize <= 0 || pos + frameSize > bytes.length) break;
      final data = bytes.sublist(pos, pos + frameSize);

      if (frameId == 'APIC') {
        _readApic(data, result);
      } else if (frameId == 'COMM') {
        final txt = _readComm(data);
        if (txt != null) result[MetaKeys.comment] = txt;
      } else if (_textFrameMap.containsKey(frameId)) {
        final text = _decodeText(data);
        final key = _textFrameMap[frameId]!;
        if (key == MetaKeys.track) {
          final trackNum = _parseLeadingInt(text);
          if (trackNum != null) result[key] = trackNum;
        } else {
          result[key] = text;
        }
      }
      pos += frameSize;
    }
    return result;
  }

  /// Reconstruit le tag ID3v2 à partir de [tags] (déjà fusionné) et le
  /// place en tête du fichier, en conservant les données audio inchangées.
  static Uint8List write(Uint8List original, Map<String, dynamic> tags) {
    int audioStart = 0;
    if (original.length >= 10 &&
        original[0] == 0x49 &&
        original[1] == 0x44 &&
        original[2] == 0x33) {
      final tagSize = _synchsafeToInt(original.sublist(6, 10));
      audioStart = 10 + tagSize;
    }
    final audio = original.sublist(audioStart);

    final frames = <int>[];

    void addText(String id, dynamic value) {
      if (value == null) return;
      final text = value.toString();
      if (text.isEmpty) return;
      frames.addAll(_buildTextFrame(id, text));
    }

    addText('TIT2', tags[MetaKeys.title]);
    addText('TPE1', tags[MetaKeys.artist]);
    addText('TALB', tags[MetaKeys.album]);
    addText('TRCK', tags[MetaKeys.track]);
    addText('TCON', tags[MetaKeys.genre]);

    final comment = tags[MetaKeys.comment] as String?;
    if (comment != null && comment.isNotEmpty) {
      frames.addAll(_buildCommFrame(comment));
    }

    final cover = tags[MetaKeys.cover] as Uint8List?;
    if (cover != null) {
      final mime = (tags[MetaKeys.coverMime] as String?) ?? 'image/jpeg';
      frames.addAll(_buildApicFrame(mime, cover));
    }

    final header = <int>[
      0x49, 0x44, 0x33, // "ID3"
      3, 0, // version 2.3.0
      0, // flags
      ..._intToSynchsafe(frames.length),
    ];

    return Uint8List.fromList([...header, ...frames, ...audio]);
  }

  // --- lecture ---------------------------------------------------------

  static String _decodeText(List<int> data) {
    if (data.isEmpty) return '';
    final encoding = data[0];
    final body = _stripTrailingNulls(data.sublist(1), encoding);
    switch (encoding) {
      case 0:
        return latin1.decode(body);
      case 1:
        return _decodeUtf16(body);
      case 2:
        return _decodeUtf16(body, bigEndianDefault: true);
      case 3:
        return utf8.decode(body, allowMalformed: true);
      default:
        return latin1.decode(body);
    }
  }

  /// Retire un éventuel terminateur nul final. En UTF-16 (encodages 1 et
  /// 2), un caractère "normal" peut très bien avoir 0x00 comme octet de
  /// poids fort (ex. 'E' -> 0x45 0x00 en UTF-16LE) : il ne faut donc
  /// retirer que si les DEUX derniers octets forment un terminateur
  /// complet (0x00 0x00), jamais un octet isolé, sous peine de décaler
  /// les paires suivantes et de tronquer le dernier caractère.
  static List<int> _stripTrailingNulls(List<int> b, int encoding) {
    if (encoding == 1 || encoding == 2) {
      if (b.length >= 2 && b[b.length - 1] == 0 && b[b.length - 2] == 0) {
        return b.sublist(0, b.length - 2);
      }
      return b;
    }
    if (b.isNotEmpty && b.last == 0) {
      return b.sublist(0, b.length - 1);
    }
    return b;
  }

  static String _decodeUtf16(List<int> b, {bool bigEndianDefault = false}) {
    if (b.length < 2) return '';
    bool bigEndian = bigEndianDefault;
    var start = 0;
    if (b[0] == 0xFF && b[1] == 0xFE) {
      bigEndian = false;
      start = 2;
    } else if (b[0] == 0xFE && b[1] == 0xFF) {
      bigEndian = true;
      start = 2;
    }
    final units = <int>[];
    for (int i = start; i + 1 < b.length; i += 2) {
      units.add(bigEndian ? (b[i] << 8) | b[i + 1] : (b[i + 1] << 8) | b[i]);
    }
    return String.fromCharCodes(units);
  }

  static int? _parseLeadingInt(String s) {
    final m = RegExp(r'\d+').firstMatch(s);
    return m == null ? null : int.tryParse(m.group(0)!);
  }

  static void _readApic(List<int> data, Map<String, dynamic> result) {
    if (data.isEmpty) return;
    final encoding = data[0];
    int i = 1;

    final mimeEnd = data.indexOf(0, i);
    if (mimeEnd == -1) return;
    final mime = latin1.decode(data.sublist(i, mimeEnd));
    i = mimeEnd + 1;

    i += 1; // octet "picture type"

    i = _skipDescription(data, i, encoding);
    if (i > data.length) return;

    result[MetaKeys.cover] = Uint8List.fromList(data.sublist(i));
    result[MetaKeys.coverMime] = mime;
  }

  static String? _readComm(List<int> data) {
    if (data.length < 5) return null;
    final encoding = data[0];
    int i = 4; // encodage(1) + langue(3)

    i = _skipDescription(data, i, encoding);
    if (i > data.length) return null;

    final textFrame = <int>[encoding, ...data.sublist(i)];
    return _decodeText(textFrame);
  }

  /// Avance [i] après une chaîne "description" terminée par un octet nul
  /// (encodages 0/3) ou deux octets nuls (encodages 1/2, UTF-16).
  static int _skipDescription(List<int> data, int i, int encoding) {
    if (encoding == 1 || encoding == 2) {
      while (i + 1 < data.length && !(data[i] == 0 && data[i + 1] == 0)) {
        i += 2;
      }
      return i + 2;
    } else {
      while (i < data.length && data[i] != 0) {
        i++;
      }
      return i + 1;
    }
  }

  // --- écriture ----------------------------------------------------------

  static bool _isLatin1(String s) => s.codeUnits.every((c) => c <= 0xFF);

  static List<int> _encodeUtf16Le(String s) {
    final out = <int>[];
    for (final unit in s.codeUnits) {
      out.add(unit & 0xFF);
      out.add((unit >> 8) & 0xFF);
    }
    return out;
  }

  static List<int> _buildTextFrame(String id, String value) {
    final List<int> payload;
    if (_isLatin1(value)) {
      payload = [0, ...latin1.encode(value)];
    } else {
      payload = [1, 0xFF, 0xFE, ..._encodeUtf16Le(value)];
    }
    return [
      ...latin1.encode(id),
      ..._intToBe(payload.length, 4),
      0, 0, // flags
      ...payload,
    ];
  }

  static List<int> _buildCommFrame(String comment) {
    final List<int> payload;
    if (_isLatin1(comment)) {
      payload = [0, ...latin1.encode('eng'), 0, ...latin1.encode(comment)];
    } else {
      payload = [
        1,
        ...latin1.encode('eng'),
        0xFF, 0xFE, 0, 0, // description vide (BOM + terminateur double-nul)
        ..._encodeUtf16Le(comment),
      ];
    }
    return [
      ...latin1.encode('COMM'),
      ..._intToBe(payload.length, 4),
      0, 0,
      ...payload,
    ];
  }

  static List<int> _buildApicFrame(String mime, Uint8List image) {
    final payload = <int>[
      0, // encodage ISO-8859-1
      ...latin1.encode(mime), 0,
      3, // type d'image : pochette (front cover)
      0, // description vide + terminateur
      ...image,
    ];
    return [
      ...latin1.encode('APIC'),
      ..._intToBe(payload.length, 4),
      0, 0,
      ...payload,
    ];
  }
}

// =======================================================================
// MP4 / M4A — atomes "ilst" façon iTunes
// =======================================================================

class _Atom {
  final String type;
  final int start; // offset absolu du début de l'atome (header inclus)
  final int headerSize; // 8 (taille normale) ou 16 (taille étendue 64 bits)
  final int totalSize; // taille totale, header inclus
  late final int dataStart;
  late final int dataEnd;

  _Atom(this.type, this.start, this.headerSize, this.totalSize) {
    dataStart = start + headerSize;
    dataEnd = start + totalSize;
  }
}

List<_Atom> _parseAtoms(Uint8List bytes, int start, int end) {
  final atoms = <_Atom>[];
  int pos = start;
  while (pos + 8 <= end) {
    int size = _beToInt(bytes.sublist(pos, pos + 4));
    final type = latin1.decode(bytes.sublist(pos + 4, pos + 8));
    int headerSize = 8;
    if (size == 1) {
      if (pos + 16 > end) break;
      size = _beToInt(bytes.sublist(pos + 8, pos + 16));
      headerSize = 16;
    } else if (size == 0) {
      size = end - pos;
    }
    if (size < headerSize || pos + size > end) break;
    atoms.add(_Atom(type, pos, headerSize, size));
    pos += size;
  }
  return atoms;
}

class Mp4Codec {
  /// Lit les métadonnées présentes dans moov/udta/meta/ilst.
  static Map<String, dynamic> read(Uint8List bytes) {
    final result = <String, dynamic>{};

    final top = _parseAtoms(bytes, 0, bytes.length);
    final moov = _firstOfType(top, 'moov');
    if (moov == null) return result;

    final moovChildren = _parseAtoms(bytes, moov.dataStart, moov.dataEnd);
    final udta = _firstOfType(moovChildren, 'udta');
    if (udta == null) return result;

    final udtaChildren = _parseAtoms(bytes, udta.dataStart, udta.dataEnd);
    final meta = _firstOfType(udtaChildren, 'meta');
    if (meta == null) return result;

    // 'meta' est une "full box" : 4 octets version/flags avant ses enfants.
    final metaChildren =
    _parseAtoms(bytes, meta.dataStart + 4, meta.dataEnd);
    final ilst = _firstOfType(metaChildren, 'ilst');
    if (ilst == null) return result;

    final items = _parseAtoms(bytes, ilst.dataStart, ilst.dataEnd);
    for (final item in items) {
      final itemChildren = _parseAtoms(bytes, item.dataStart, item.dataEnd);
      final data = _firstOfType(itemChildren, 'data');
      if (data == null) continue;
      // atome 'data' : [taille(4)][type "data"(4)][indicateur(4)][locale(4)][charge utile]
      if (data.dataEnd - data.dataStart < 8) continue;
      final payload = bytes.sublist(data.dataStart + 8, data.dataEnd);

      switch (item.type) {
        case '\u00A9nam':
          result[MetaKeys.title] = utf8.decode(payload, allowMalformed: true);
          break;
        case '\u00A9ART':
          result[MetaKeys.artist] =
              utf8.decode(payload, allowMalformed: true);
          break;
        case '\u00A9alb':
          result[MetaKeys.album] = utf8.decode(payload, allowMalformed: true);
          break;
        case '\u00A9cmt':
          result[MetaKeys.comment] =
              utf8.decode(payload, allowMalformed: true);
          break;
        case '\u00A9gen':
          result[MetaKeys.genre] = utf8.decode(payload, allowMalformed: true);
          break;
        case 'trkn':
          if (payload.length >= 4) {
            result[MetaKeys.track] = _beToInt(payload.sublist(2, 4));
          }
          break;
      }
    }
    return result;
  }

  /// Reconstruit l'atome moov avec un nouvel "ilst" (fusionné en amont),
  /// puis réinjecte le résultat dans le fichier en corrigeant au besoin
  /// les tables de décalage stco/co64 si moov précède mdat et que sa
  /// taille a changé.
  static Uint8List write(Uint8List original, Map<String, dynamic> tags) {
    final top = _parseAtoms(original, 0, original.length);
    final moovAtom = _firstOfType(top, 'moov');
    if (moovAtom == null) {
      throw StateError('Atome "moov" introuvable : fichier MP4 invalide ?');
    }
    final mdatAtom = _firstOfType(top, 'mdat');

    var moovBytes = original.sublist(moovAtom.start, moovAtom.dataEnd);
    final oldMoovLen = moovBytes.length;

    final newIlst = _buildIlst(tags);

    // udta (créé s'il est absent)
    final udtaAtoms = _parseAtoms(moovBytes, 8, moovBytes.length)
        .where((a) => a.type == 'udta')
        .toList();
    List<int> udtaBytes = udtaAtoms.isNotEmpty
        ? moovBytes.sublist(udtaAtoms.first.start, udtaAtoms.first.dataEnd)
        : [..._intToBe(8, 4), ...latin1.encode('udta')];

    // meta (full box, créé s'il est absent)
    final metaAtoms = _parseAtoms(
      Uint8List.fromList(udtaBytes),
      8,
      udtaBytes.length,
    ).where((a) => a.type == 'meta').toList();
    List<int> metaBytes = metaAtoms.isNotEmpty
        ? udtaBytes.sublist(metaAtoms.first.start, metaAtoms.first.dataEnd)
        : [
      ..._intToBe(12, 4),
      ...latin1.encode('meta'),
      0, 0, 0, 0, // version + flags
    ];

    final newMetaBytes =
    _spliceChild(metaBytes, 'ilst', newIlst, extraHeader: 4);
    final newUdtaBytes = _spliceChild(udtaBytes, 'meta', newMetaBytes);
    final newMoovBytes = _spliceChild(moovBytes, 'udta', newUdtaBytes);

    moovBytes = Uint8List.fromList(newMoovBytes);
    final delta = moovBytes.length - oldMoovLen;

    if (delta != 0 && mdatAtom != null && moovAtom.start < mdatAtom.start) {
      _shiftChunkOffsets(moovBytes, delta);
    }

    final result = <int>[];
    result.addAll(original.sublist(0, moovAtom.start));
    result.addAll(moovBytes);
    result.addAll(original.sublist(moovAtom.dataEnd));
    return Uint8List.fromList(result);
  }

  static _Atom? _firstOfType(List<_Atom> atoms, String type) {
    for (final a in atoms) {
      if (a.type == type) return a;
    }
    return null;
  }

  /// Remplace (ou ajoute en fin de liste) l'enfant [childType] à
  /// l'intérieur d'un conteneur d'atomes, et met à jour le champ de
  /// taille (4 octets, big-endian) du conteneur en conséquence.
  /// [extraHeader] permute le nombre d'octets à ignorer avant les enfants
  /// (ex. 4 pour une "full box" comme 'meta').
  static List<int> _spliceChild(
      List<int> container,
      String childType,
      List<int> newChildBytes, {
        int extraHeader = 0,
      }) {
    final childrenStart = 8 + extraHeader;
    final atoms = _parseAtoms(
      Uint8List.fromList(container),
      childrenStart,
      container.length,
    );
    _Atom? existing;
    for (final a in atoms) {
      if (a.type == childType) {
        existing = a;
        break;
      }
    }

    final List<int> before;
    final List<int> after;
    if (existing != null) {
      before = container.sublist(0, existing.start);
      after = container.sublist(existing.dataEnd);
    } else {
      before = container;
      after = const [];
    }

    final newContainer = <int>[...before, ...newChildBytes, ...after];
    final sizeBytes = _intToBe(newContainer.length, 4);
    for (int i = 0; i < 4; i++) {
      newContainer[i] = sizeBytes[i];
    }
    return newContainer;
  }

  /// Décale de [delta] octets tous les offsets stockés dans les atomes
  /// 'stco' (32 bits) et 'co64' (64 bits) trouvés récursivement dans
  /// [moovBytes] (offsets locaux au buffer moov, modifiés en place).
  static void _shiftChunkOffsets(List<int> moovBytes, int delta) {
    const containers = {'trak', 'mdia', 'minf', 'stbl'};

    void walk(int start, int end) {
      final atoms = _parseAtoms(Uint8List.fromList(moovBytes), start, end);
      for (final a in atoms) {
        if (a.type == 'stco' || a.type == 'co64') {
          final entrySize = a.type == 'stco' ? 4 : 8;
          final entryCountPos = a.dataStart + 4;
          if (entryCountPos + 4 > moovBytes.length) continue;
          final entryCount = _beToInt(
            moovBytes.sublist(entryCountPos, entryCountPos + 4),
          );
          var p = entryCountPos + 4;
          for (int i = 0; i < entryCount && p + entrySize <= moovBytes.length; i++) {
            final oldOffset = _beToInt(moovBytes.sublist(p, p + entrySize));
            final newOffset = oldOffset + delta;
            final nb = _intToBe(newOffset, entrySize);
            for (int k = 0; k < entrySize; k++) {
              moovBytes[p + k] = nb[k];
            }
            p += entrySize;
          }
        } else if (containers.contains(a.type)) {
          walk(a.dataStart, a.dataEnd);
        }
      }
    }

    walk(8, moovBytes.length);
  }

  static List<int> _buildIlst(Map<String, dynamic> tags) {
    final items = <int>[];

    void addText(String type, dynamic value) {
      if (value == null) return;
      final text = value.toString();
      if (text.isEmpty) return;
      final textBytes = utf8.encode(text);
      final data = <int>[
        ..._intToBe(16 + textBytes.length, 4),
        ...latin1.encode('data'),
        ..._intToBe(1, 4), // indicateur de type : 1 = UTF-8
        0, 0, 0, 0, // locale
        ...textBytes,
      ];
      items.addAll([
        ..._intToBe(8 + data.length, 4),
        ...latin1.encode(type),
        ...data,
      ]);
    }

    addText('\u00A9nam', tags[MetaKeys.title]);
    addText('\u00A9ART', tags[MetaKeys.artist]);
    addText('\u00A9alb', tags[MetaKeys.album]);
    addText('\u00A9cmt', tags[MetaKeys.comment]);
    addText('\u00A9gen', tags[MetaKeys.genre]);

    final track = tags[MetaKeys.track];
    if (track is int) {
      final payload = <int>[
        0, 0, // réservé
        ..._intToBe(track, 2),
        0, 0, // nombre total de pistes : inconnu
        0, 0, // réservé
      ];
      final data = <int>[
        ..._intToBe(16 + payload.length, 4),
        ...latin1.encode('data'),
        ..._intToBe(0, 4), // indicateur de type : 0 = binaire
        0, 0, 0, 0,
        ...payload,
      ];
      items.addAll([
        ..._intToBe(8 + data.length, 4),
        ...latin1.encode('trkn'),
        ...data,
      ]);
    }

    return [
      ..._intToBe(8 + items.length, 4),
      ...latin1.encode('ilst'),
      ...items,
    ];
  }
}
