import 'music_service.dart';
import 'playlist_service.dart';
import 'like_service.dart';
import 'library_service.dart';
import 'settings_service.dart';

class ServiceLocator {
  static final MusicService music = MusicService();
  static final PlaylistService playlists = PlaylistService();
  static final LikeService likes = LikeService();
  static final LibraryService library = LibraryService();
  static final SettingsService settings = SettingsService();

  static Future<void> dispose() async {
    await music.dispose();
    playlists.dispose();
    likes.dispose();
    library.dispose();
  }
}
