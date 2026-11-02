import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/models.dart';

class MusicService extends ChangeNotifier {
  MusicService() {
    _youtube = YoutubeExplode();
  }

  late final YoutubeExplode _youtube;

  bool _searching = false;
  String? _error;
  DateTime? _lastSearch;

  bool get searching => _searching;
  String? get error => _error;
  bool get hasSearched => _lastSearch != null;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _error = null;
      _lastSearch = null;
      notifyListeners();
      return;
    }

    _searching = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _youtube.search
          .get(query.trim(), options: const SearchOptions(maxResults: 40));
      final tracks = <Track>[];
      for (final result in results) {
        if (result.type != VideoType.video) continue;
        final info = await _youtube.videos.get(result.id);
        final stream = await _youtube.videos.streams.get(info.id);
        final audio = stream?.audio;
        String? audioUrl;
        if (audio != null) {
          audioUrl = audio.url.toString();
        }
        tracks.add(Track(
          id: 'yt_${info.id.value}',
          title: info.title,
          artist: info.author.name,
          album: info.author.name,
          duration: info.duration.inSeconds,
          artwork:
              info.thumbnails.lastOrNull?.url.toString() ??
              info.thumbnails.firstOrNull?.url.toString(),
          source: 'YouTube',
          license: 'See source',
          url: audioUrl,
          artistUrl: 'https://www.youtube.com/@${info.author.channelId.value}',
        ));
        if (trax.length >= 30) break;
      }

      tracks.sort((a, b) => b.duration.compareTo(a.duration));
      _lastSearch = DateTime.now();
      _error = null;
      notifyListeners();
      return tracks;
    } on YoutubeExplodeException catch (e) {
      _error = 'Search failed: ${e.message}';
      notifyListeners();
      return <Track>[];
    } catch (e) {
      _error = 'Search failed unexpectedly.';
      notifyListeners();
      return <Track>[];
    } finally {
      _searching = false;
      notifyListeners();
    }
  }

  Future<AudioStreamInfo?> streamInfo(String videoId) async {
    try {
      final info = await _youtube.videos.get(VideoId(videoId));
      final stream = await _youtube.videos.streams.get(info.id);
      final audio = stream?.audio;
      if (audio == null) return null;
      return AudioStreamInfo(
        url: audio.url.toString(),
        bitrate: audio.bitrate?.inBitsPerSecond ?? 0,
        codec: audio.codec.name,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> dispose() async {
    await _youtube.close();
    super.dispose();
  }
}

class AudioStreamInfo {
  const AudioStreamInfo({
    required this.url,
    required this.bitrate,
    required this.codec,
  });
  final String url;
  final int bitrate;
  final String codec;
}
