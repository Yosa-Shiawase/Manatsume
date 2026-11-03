import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../models/models.dart';

class PlaylistService extends ChangeNotifier {
  PlaylistService() {
    _init();
  }

  final Uuid _id = const Uuid();

  static const _dirName = 'manatsume_playlists';

  late final Directory _dir;
  final Map<String, Playlist> _playlists = {};
  bool _loaded = false;

  Map<String, Playlist> get all => Map.unmodifiable(_playlists);
  List<Playlist> get list => _playlists.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

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

  Future<void> _load() async {
    if (!_loaded) {
      try {
        await for (final entity in _dir.list()) {
          if (entity is File && entity.path.endsWith('.json')) {
            try {
              final bytes = entity.readAsBytesSync();
              final jsonStr = utf8.decode(bytes);
              final data = jsonDecode(jsonStr) as Map<String, dynamic>;
              final playlist = Playlist.fromJson(data);
              _playlists[playlist.id] = playlist;
            } catch (_) {
              // ignore corrupt playlist file
            }
          }
        }
      } catch (_) {}
      _loaded = true;
      notifyListeners();
    }
  }

  Future<Playlist> create(String name, {String? description}) async {
    if (_dir == null) await _init();
    final playlist = Playlist(
      id: _id.v4(),
      name: name.trim(),
      description: description?.trim(),
      tracks: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _save(playlist);
    _playlists[playlist.id] = playlist;
    notifyListeners();
    return playlist;
  }

  Future<void> rename(String id, String name) async {
    final playlist = _playlists[id];
    if (playlist == null) return;
    final next = playlist.copyWith(name: name.trim(), updatedAt: DateTime.now());
    await _save(next);
    _playlists[id] = next;
    notifyListeners();
  }

  Future<void> updateDescription(String id, String? description) async {
    final playlist = _playlists[id];
    if (playlist == null) return;
    final next = playlist.copyWith(
      description: description?.trim(),
      updatedAt: DateTime.now(),
    );
    await _save(next);
    _playlists[id] = next;
    notifyListeners();
  }

  Future<void> addTrack(String playlistId, Track track) async {
    final playlist = _playlists[playlistId];
    if (playlist == null) return;
    if (playlist.tracks.any((t) => t.id == track.id)) return;
    final next = playlist.copyWith(
      tracks: [...playlist.tracks, track],
      updatedAt: DateTime.now(),
    );
    await _save(next);
    _playlists[playlistId] = next;
    notifyListeners();
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    final playlist = _playlists[playlistId];
    if (playlist == null) return;
    final next = playlist.copyWith(
      tracks: playlist.tracks.where((t) => t.id != trackId).toList(),
      updatedAt: DateTime.now(),
    );
    await _save(next);
    _playlists[playlistId] = next;
    notifyListeners();
  }

  Future<void> reorderTracks(String playlistId, int oldIndex, int newIndex) async {
    final playlist = _playlists[playlistId];
    if (playlist == null) return;
    final tracks = List<Track>.from(playlist.tracks);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, item);
    final next = playlist.copyWith(
      tracks: tracks,
      updatedAt: DateTime.now(),
    );
    await _save(next);
    _playlists[playlistId] = next;
    notifyListeners();
  }

  Future<void> delete(String playlistId) async {
    final playlist = _playlists[playlistId];
    if (playlist == null) return;
    await _removeFile(playlistId);
    _playlists.remove(playlistId);
    notifyListeners();
  }

  Future<void> _save(Playlist playlist) async {
    final file = File(path.join(_dir.path, '${playlist.id}.json'));
    final jsonStr = const JsonEncoder.withIndent('  ').convert(playlist.toJson());
    await file.writeAsString(jsonStr, flush: true);
  }

  Future<void> _removeFile(String id) async {
    try {
      final file = File(path.join(_dir.path, '$id.json'));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
