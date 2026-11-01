# Manatsume

Manatsume is a free, installable music player with your own playlists, search across free music sources, and a calm night-themed experience. It is built as a downloadable PWA you can install in Chrome and use like an app.

## What Manatsume is

- A music player with search, playlists, library, and a persistent player
- Night-themed design with fox mascot and subtle motion
- Free music sources plus your own files
- Offline-capable PWA shell and local cover caching

## Architecture

- React + TypeScript + Vite
- Tailwind CSS for styling
- Framer Motion for animations
- IndexedDB and Service Worker for local caching
- Client-side player controller with queue, shuffle, repeat, and seek

## Getting started

Install dependencies, then run the dev server.

```sh
npm install
npm run dev
```

Open the preview URL in your browser. The app is installable when served over HTTPS or from localhost.

## Project structure

```
src/
  App.tsx
  components/
  hooks/
  lib/
  routes/
  sections/
  storage/
  providers/
  types.ts
public/
  manifest.json
```

## Music sourcing

Manatsume plays music from free music sources and from your own files. Each track keeps the license and source that came with it. That means:

- Free source tracks show the artist, source, and license where available
- Your own files stay on your device and are played locally
- The app does not claim to own the music it plays

This is how Manatsume stays honest about music licensing.

## License

The app code is released under the MIT License. Music in Manatsume is governed by the license of each track and by the terms of the source it came from.

## Development notes

- The app is designed to feel calm, premium, and animated without being noisy
- Motion is used on route transitions, cards, and the player
- The player is kept alive across navigation so playback continues as you browse
- The theme can be switched between night, night-warm, and paper

## Roadmap

- Real backend and user accounts
- Collaborative playlists and sync
- More free music sources
- Better offline and caching controls
- More polish and accessibility work

## Contributing

Manatsume is a personal project. If you want to contribute, start by reading the code in `src/` and making small, focused changes.

## Credits

Made with care by Yosa-Shiawase.

The fox mascot is inspired by the fox art in the 404startup project.
