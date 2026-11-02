import 'dart:convert';

class Track implements Comparable<Track> {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.duration,
    this.artwork,
    this.source,
    this.license,
    this.url,
    this.artistUrl,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final int duration;
  final String? artwork;
  final String? source;
  final String? license;
  final String? url;
  final String? artistUrl;

  @override
  int compareTo(Track other) {
    final byTitle = title.toLowerCase().compareTo(other.title.toLowerCase());
    if (byTitle != 0) return byTitle;
    return artist.toLowerCase().compareTo(other.artist.toLowerCase());
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String?,
      duration: json['duration'] as int? ?? 0,
      artwork: json['artwork'] as String?,
      source: json['source'] as String?,
      license: json['license'] as String?,
      url: json['url'] as String?,
      artistUrl: json['artistUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'duration': duration,
    'artwork': artwork,
    'source': source,
    'license': license,
    'url': url,
    'artistUrl': artistUrl,
  };
}

class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.tracks,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final List<Track> tracks;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist copyWith({
    String? name,
    String? description,
    List<Track>? tracks,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      tracks: tracks ?? this.tracks,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((e) => Track.fromJson(e as Map<String, dynamic>))
              .toList() ?? const [],
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'tracks': tracks.map((t) => t.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  int totalDuration() => tracks.fold(0, (sum, t) => sum + t.duration);
  String totalDurationFormatted() {
    final total = totalDuration();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) return '$h h $m min';
    if (m > 0) return '$m min ${s}s';
    return '${s}s';
  }

  String trackCountText() {
    final n = tracks.length;
    if (n == 0) return 'Empty playlist';
    if (n == 1) return '1 track';
    return '$n tracks';
  }
}

class LocalTrack {
  const LocalTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.duration,
    required this.fileType,
    required this.filePath,
    this.thumbnailPath,
    required this.size,
    required this.addedAt,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final int duration;
  final String fileType;
  final String filePath;
  final String? thumbnailPath;
  final int size;
  final DateTime addedAt;

  LocalTrack copyWith({
    String? title,
    String? artist,
    String? album,
    int? duration,
    String? fileType,
    String? filePath,
    String? thumbnailPath,
  }) {
    return LocalTrack(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      fileType: fileType ?? this.fileType,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      size: size,
      addedAt: addedAt,
    );
  }

  factory LocalTrack.fromJson(Map<String, dynamic> json) {
    return LocalTrack(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String?,
      duration: json['duration'] as int? ?? 0,
      fileType: json['fileType'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      thumbnailPath: json['thumbnailPath'] as String?,
      size: json['size'] as int? ?? 0,
      addedAt: DateTime.parse(json['addedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'duration': duration,
    'fileType': fileType,
    'filePath': filePath,
    'thumbnailPath': thumbnailPath,
    'size': size,
    'addedAt': addedAt.toIso8601String(),
  };

  String formattedDuration() {
    final h = duration ~/ 3600;
    final m = (duration % 3600) ~/ 60;
    final s = duration % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  String formattedSize() {
    final bytes = size;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
