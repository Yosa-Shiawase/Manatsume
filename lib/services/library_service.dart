import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../models/models.dart';

class LibraryService extends ChangeNotifier {
  LibraryService() {
    _init();
  }

  final Uuid _id = const Uuid();

  static const _dirName = 'manatsume_library';

  late final Directory _dir;
  final Map<String, LocalTrack> _tracks = {};
  bool _loaded = false;

  Map<String, LocalTrack> get all => Map.unmodifiable(_tracks);
  List<LocalTrack> get list => _tracks.values.toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

  Future<void> _init() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _dir = Directory(path.join(appDir.path, _dirName));
      if (!await _dir.exists()) {
        await _dir.create(recursive: true);
      }
      _load();
    } catch (e) {
      _dir = Directory.systemTemp;
      _load();
    }
  }

  void _load() {
    if (!_loaded) {
      try {
        await for (final entity in _dir.list()) {
          if (entity is File && entity.path.endsWith('.json')) {
            try {
              final bytes = entity.readAsBytesSync();
              final jsonStr = utf8.decode(bytes);
              final data = jsonDecode(jsonStr) as Map<String, dynamic>;
              final track = LocalTrack.fromJson(data);
              _tracks[track.id] = track;
            } catch (_) {}
          }
        }
      } catch (_) {}
      _loaded = true;
      notifyListeners();
    }
  }

  Future<LocalTrack> addFile(File file) async {
    if (_dir == null) await _init();
    final id = _id.v4();
    final ext = path.extension(file.path);
    final metadata = _guessMetadata(file, ext);
    final thumbId = _id.v4();
    final thumbPath = path.join(_dir.path, 'thumbs', thumbId);
    await _ensureThumbDir();
    try {
      await file.copy(thumbPath);
    } catch (_) {
      // not every file can be used as a thumbnail; that's fine
    }
    final track = LocalTrack(
      id: id,
      title: metadata.title,
      artist: metadata.artist,
      album: metadata.album,
      duration: metadata.duration,
      fileType: ext.toUpperCase().replaceFirst('.', ''),
      filePath: file.path,
      thumbnailPath: thumbPath,
      size: await file.length(),
      addedAt: DateTime.now(),
    );
    await _save(track);
    _tracks[id] = track;
    notifyListeners();
    return track;
  }

  Future<void> _ensureThumbDir() async {
    final thumbDir = Directory(path.join(_dir.path, 'thumbs'));
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
  }

  Future<void> delete(String id) async {
    final track = _tracks[id];
    if (track == null) return;
    try {
      final file = File(track.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
    try {
      final thumb = File(track.thumbnailPath);
      if (await thumb.exists()) {
        await thumb.delete();
      }
    } catch (_) {}
    _tracks.remove(id);
    notifyListeners();
  }

  Future<void> rename(String id, String title) async {
    final track = _tracks[id];
    if (track == null) return;
    final next = track.copyWith(title: title.trim());
    await _save(next);
    _tracks[id] = next;
    notifyListeners();
  }

  Future<void> setArtist(String id, String artist) async {
    final track = _tracks[id];
    if (track == null) return;
    final next = track.copyWith(artist: artist.trim());
    await _save(next);
    _tracks[id] = next;
    notifyListeners();
  }

  Future<void> setAlbum(String id, String album) async {
    final track = _tracks[id];
    if (track == null) return;
    final next = track.copyWith(album: album?.trim());
    await _save(next);
    _tracks[id] = next;
    notifyListeners();
  }

  Future<void> _save(LocalTrack track) async {
    final file = File(path.join(_dir.path, '${track.id}.json'));
    final jsonStr = const JsonEncoder.withIndent('  ').convert(track.toJson());
    await file.writeAsString(jsonStr, flush: true);
  }

  Metadata _guessMetadata(File file, String ext) {
    final name = path.basenameWithoutExtension(file.path);
    final parts = name.split(RegExp(r'[-_\s]+'));
    final title = name.isEmpty ? 'Untitled' : name;
    final artist = parts.isNotEmpty ? parts.first : 'Unknown';
    final album = parts.length > 2 ? parts.getRange(1, parts.length - 1).join(' ') : null;
    return Metadata(
      title: title,
      artist: artist,
      album: album,
      duration: 0,
    );
  }
}

class Metadata {
  const Metadata({
    required this.title,
    required this.artist,
    this.album,
    required this.duration,
  });
  final String title;
  final String artist;
  final String? album;
  final int duration;
}
