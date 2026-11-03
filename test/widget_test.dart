import 'package:flutter_test/flutter_test.dart';
import 'package:manatsume/models/models.dart';

void main() {
  test('Track JSON roundtrip preserves fields', () {
    final track = Track(
      id: 'yt_abc123',
      title: 'Test Song',
      artist: 'Test Artist',
      album: 'Test Album',
      duration: 180,
      artwork: 'https://example.com/art.jpg',
      source: 'YouTube',
      url: 'https://example.com/stream',
    );

    final json = track.toJson();
    final restored = Track.fromJson(json);

    expect(restored.id, track.id);
    expect(restored.title, track.title);
    expect(restored.artist, track.artist);
    expect(restored.album, track.album);
    expect(restored.duration, track.duration);
    expect(restored.artwork, track.artwork);
    expect(restored.source, track.source);
    expect(restored.url, track.url);
  });

  test('Track.fromJson tolerates missing fields', () {
    final track = Track.fromJson({});
    expect(track.id, '');
    expect(track.title, '');
    expect(track.artist, '');
    expect(track.duration, 0);
  });

  test('Playlist duration formatting', () {
    final playlist = Playlist(
      id: 'p1',
      name: 'Night drive',
      tracks: [
        Track(id: 'a', title: 'A', artist: 'X', duration: 65),
        Track(id: 'b', title: 'B', artist: 'Y', duration: 125),
      ],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    expect(playlist.trackCountText(), '2 tracks');
    expect(playlist.totalDuration(), 190);
    expect(playlist.totalDurationFormatted(), '3 min 10s');
  });
}
