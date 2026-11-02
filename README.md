# Manatsume

A mobile music app built to study how a reverse-engineered YouTube search
and stream pipeline fits into a real player.

## What this is

Manatsume is a Flutter app with two jobs:

1. Search and play music using `youtube_explode_dart`, which extracts search
   results, metadata, and audio stream URLs from YouTube without an official
   YouTube API key.
2. Play your own local audio files, manage playlists, and keep a player that
   stays with you across the app.

The interesting engineering layer is the reverse-engineering path: this repo
is structured so you can open it and see how an app can obtain stream URLs and
metadata through an extractor rather than through a public API.

## What it is not

It is not an official YouTube app and it does not use a YouTube API key.
Extractor-based access is inherently fragile: YouTube changes things, and the
extractor can break or return different results over time. This repo treats
that as a known limitation, not as a bug to pretend away.

It is also not a music catalog, licenses, or redistribution service. The app
streams from URLs it obtains at runtime and does not re-host audio. If you use
it with content you do not own or have permission to use, that is on you.

## Stack

- Flutter + Dart.
- `youtube_explode_dart` for YouTube search and stream extraction.
- `just_audio` for playback.
- Local SQLite-like storage for playlists, likes, and library metadata via
  `shared_preferences`-style local persistence and file-based local music.
- Custom motion system built on Flutter's animation primitives, with separate
  signatures for each major action.

## Getting the APK

You need the Flutter SDK installed locally. Then:

```bash
flutter pub get
flutter build apk --release
```

The release APK is produced at:

```
build/app/outputs/flutter-apk/app-release.apk
```

You can then upload that APK from the GitHub repo, or publish it from a
GitHub Actions workflow that runs the same build.

If you want an APK shipped from GitHub automatically, add a GitHub Actions
workflow that checks out the repo, sets up Flutter, runs `flutter build apk`,
and uploads the artifact. The workflow is not included by default because this
repo is meant to be studied and forked, not to assume a particular CI host.

## Honest limitations

- YouTube search and stream availability depend on YouTube and on the extractor
  package staying current.
- Some tracks may not have a playable stream URL, or may be region/content
  restricted.
- Local files stay on the device; the app does not upload them anywhere.

## License

The app code is MIT. Music sourcing is a separate matter: the app does not
claim rights to any music it plays, and it streams from runtime URLs rather
than bundling audio.
