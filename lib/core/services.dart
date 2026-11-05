import '../services/settings_service.dart';
import '../services/library_service.dart';
import '../services/like_service.dart';
import '../services/music_service.dart';
import '../services/playlist_service.dart';

// Re-export the service types so pages importing ServiceLocator can also
// reference MusicService and friends in their own signatures.
export '../services/settings_service.dart';
export '../services/library_service.dart';
export '../services/like_service.dart';
export '../services/music_service.dart';
export '../services/playlist_service.dart';

class ServiceLocator {
  static final MusicService music = MusicService();
  static final PlaylistService playlists = PlaylistService();
  static final LikeService likes = LikeService();
  static final LibraryService library = LibraryService();
  static final SettingsService settings = SettingsService();

  static Future<void> dispose() async {
    music.dispose();
    playlists.dispose();
    likes.dispose();
    library.dispose();
  }
}
