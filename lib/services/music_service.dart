import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/models.dart';

/// Streams music from YouTube using reverse-engineered endpoints
/// (youtube_explode_dart — no official API key, no quota).
/// Actual audio playback runs through just_audio (ExoPlayer on Android).
class MusicService extends ChangeNotifier {
  MusicService() {
    _youtube = YoutubeExplode();
    _player = AudioPlayer();
    _player.playerStateStream.listen((_) => _syncState());
  }

  late final YoutubeExplode _youtube;
  late final AudioPlayer _player;

  Track? _current;
  List<Track> _results = const <Track>[];
  bool _searching = false;
  bool _playing = false;
  bool _buffering = false;
  String? _error;
  DateTime? _lastSearch;

  bool get searching => _searching;
  bool get playing => _playing;
  bool get buffering => _buffering;
  String? get error => _error;
  bool get hasSearched => _lastSearch != null;
  Track? get currentTrack => _current;
  List<Track> get results => _results;
  AudioPlayer get player => _player;

  Future<List<Track>> search(String query) async {
    if (query.trim().isEmpty) {
      _error = null;
      _lastSearch = null;
      _results = const <Track>[];
      notifyListeners();
      return <Track>[];
    }

    _searching = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _youtube.search
          .search(query.trim(), filter: TypeFilters.video);
      final tracks = <Track>[];
      for (final video in results.take(40)) {
        tracks.add(Track(
          id: 'yt_${video.id.value}',
          title: video.title,
          artist: video.author,
          album: video.author,
          duration: video.duration?.inSeconds ?? 0,
          artwork: video.thumbnails.highResUrl,
          source: 'YouTube',
          license: 'https://www.youtube.com/t/terms',
          url: null,
          artistUrl: 'https://www.youtube.com/channel/${video.channelId.value}',
        ));
      }

      _lastSearch = DateTime.now();
      _results = tracks;
      _error = null;
      notifyListeners();
      return tracks;
    } on Exception catch (e) {
      _results = const <Track>[];
      _error = 'Search failed: ${e.toString()}';
      notifyListeners();
      return <Track>[];
    } catch (e) {
      _results = const <Track>[];
      _error = 'Search failed unexpectedly.';
      notifyListeners();
      return <Track>[];
    } finally {
      _searching = false;
      notifyListeners();
    }
  }

  /// Resolves a direct audio URL for a YouTube-backed track.
  Future<String?> resolveStreamUrl(String trackId) async {
    final videoId = trackId.startsWith('yt_') ? trackId.substring(3) : trackId;
    try {
      final manifest = await _youtube.videos.streamsClient
          .getManifest(VideoId(videoId));
      if (manifest.audioOnly.isEmpty) return null;
      final stream = manifest.audioOnly.withHighestBitrate();
      return stream.url.toString();
    } catch (_) {
      return null;
    }
  }

  /// Plays a track: resolves its audio stream lazily, then starts playback.
  Future<void> play(Track track) async {
    _current = track;
    _buffering = true;
    _error = null;
    notifyListeners();
    try {
      final url = track.url ?? await resolveStreamUrl(track.id);
      if (url == null) {
        _error = 'Could not resolve an audio stream for this track.';
        _buffering = false;
        notifyListeners();
        return;
      }
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      _error = 'Playback failed: ${e.toString()}';
      _buffering = false;
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (_current == null) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0.0, 1.0));

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> stop() async {
    await _player.stop();
    _playing = false;
    _buffering = false;
    notifyListeners();
  }

  void _syncState() {
    final playing = _player.playing;
    final buffering = _player.processingState == ProcessingState.buffering ||
        _player.processingState == ProcessingState.loading;
    if (playing != _playing || buffering != _buffering) {
      _playing = playing;
      _buffering = buffering;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _youtube.close();
    _player.dispose();
    super.dispose();
  }
}
