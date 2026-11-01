import { useState, useEffect, useCallback } from 'react';
import { motion } from 'framer-motion';
import { Search, Heart, Plus, Play, Loader2, ExternalLink } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import type { Track } from '../types';
import { jamSearchUrl, JamSearchResult } from '../lib/jamendo';

const DEMO_TRACKS: Track[] = [
  {
    id: 't1',
    title: 'Midnight Signal',
    artist: 'Long Summer Night',
    album: 'Night Sessions',
    duration: 214,
    artwork: 'https://picsum.photos/seed/t1/400/400',
    source: 'Jamendo',
    license: 'CC BY',
  },
  {
    id: 't2',
    title: 'Paper Fox',
    artist: 'Ink Studio',
    album: 'Sketchbook Tapes',
    duration: 188,
    artwork: 'https://picsum.photos/seed/t2/400/400',
    source: 'Jamendo',
    license: 'CC BY',
  },
  {
    id: 't3',
    title: 'Static Lullaby',
    artist: 'Echo Room',
    duration: 243,
    artwork: 'https://picsum.photos/seed/t3/400/400',
    source: 'Jamendo',
    license: 'CC BY-NC',
  },
  {
    id: 't4',
    title: 'Late Night Waves',
    artist: 'Tidal Haze',
    album: 'Nocturnes',
    duration: 201,
    artwork: 'https://picsum.photos/seed/t4/400/400',
    source: 'Jamendo',
    license: 'CC BY-SA',
  },
  {
    id: 't5',
    title: 'Foxglove',
    artist: 'Ink Garden',
    duration: 176,
    artwork: 'https://picsum.photos/seed/t5/400/400',
    source: 'Jamendo',
    license: 'CC BY',
  },
];

export default function SearchPage() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<Track[]>(DEMO_TRACKS);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [liked, setLiked] = useState<Set<string>>(new Set());

  const isConfigured = Boolean(
    typeof import.meta !== 'undefined' && import.meta.env?.VITE_JAMENDO_CLIENT_ID,
  );

  useEffect(() => {
    if (!query.trim()) {
      setResults(DEMO_TRACKS);
      setError(null);
      return;
    }
    if (!isConfigured || !user) {
      const q = query.toLowerCase();
      setResults(
        DEMO_TRACKS.filter(
          (t) =>
            t.title.toLowerCase().includes(q) ||
            t.artist.toLowerCase().includes(q) ||
            (t.album && t.album.toLowerCase().includes(q)),
        ),
      );
      setError(null);
      return;
    }

    let cancelled = false;
    setLoading(true);
    setError(null);
    try {
      const url = jamSearchUrl(undefined, query, 25);
      fetch(url)
        .then((r) => r.json())
        .then((json) => {
          if (cancelled) return;
          const list = (json?.results as JamSearchResult[] | undefined) ?? [];
          const tracks: Track[] = list.map((track) => ({
            id: `jam-${track.id}`,
            title: track.title,
            artist: track.artist_name,
            album: track.album_name ?? undefined,
            duration: Math.round((track.duration ?? 0) / 1000),
            artwork: track.album_image ?? `https://picsum.photos/seed/${track.id}/400/400`,
            source: 'Jamendo',
            license: track.license ?? 'See Jamendo',
            artistUrl: `https://www.jamendo.com/artist/${encodeURIComponent(track.artist_name)}`,
            url: track.stream ?? track.audio ?? undefined,
          }));
          setResults(tracks);
          setError(null);
        })
        .catch(() => {
          if (cancelled) return;
          setError('Search failed. Check your connection and that Jamendo is configured.');
          setResults(DEMO_TRACKS);
        });
      return () => {
        cancelled = true;
      };
    } catch {
      if (!cancelled) {
        setError('Search setup failed.');
        setResults(DEMO_TRACKS);
      }
    }
  }, [query, isConfigured, user, liked]);

  const toggleLike = useCallback(
    (id: string) => {
      setLiked((prev) => {
        const next = new Set(prev);
        if (next.has(id)) next.delete(id);
        else next.add(id);
        return next;
      });
    },
    [],
  );

  const playTrack = useCallback(
    (track: Track) => {
      navigate('/player', {
        state: { track, queue: results, replace: true },
      });
    },
    [navigate, results],
  );

  const createPlaylist = useCallback((name: string) => {
    if (!user) return;
    const id = name.toLowerCase().replace(/\s+/g, '-') + '-' + Date.now().toString(36);
    try {
      const key = `playlist:${id}`;
      localStorage.setItem(key, JSON.stringify([]));
    } catch {
      // ignore
    }
  }, [user]);

  return (
    <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans selection:bg-[var(--color-accent)]/30">
      <header className="sticky top-0 z-30 flex items-center justify-between px-5 py-3 border-b border-[var(--color-border)] bg-[var(--color-bg)]/80 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <a href="/" className="text-lg font-semibold tracking-tight">Manatsume</a>
          <nav className="hidden md:flex items-center gap-4 text-sm text-[var(--color-muted)] ml-6">
            <a href="/" className="hover:text-[var(--color-text)]">Home</a>
            <a href="/library" className="hover:text-[var(--color-text)]">Library</a>
          </nav>
        </div>
        <div className="flex items-center gap-2">
          <a
            href="/player"
            className="px-4 py-2 rounded-full text-sm border border-[var(--color-border)] bg-[var(--color-surface)] hover:border-[var(--color-accent)]/50 transition flex items-center gap-2"
          >
            <Play className="w-4 h-4" />
            Player
          </a>
        </div>
      </header>

      <section className="max-w-5xl mx-auto px-5 py-12">
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          className="max-w-3xl"
        >
          <h1 className="text-3xl font-semibold mb-2">Search</h1>
          <p className="text-sm text-[var(--color-muted)] mb-6">
            Find free music from Jamendo and your library. Each track shows its artist credit and license.
          </p>

          <div className="relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-[var(--color-muted)]" />
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search songs, artists, albums..."
              className="w-full h-12 pl-12 pr-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] text-[var(--color-text)] placeholder-[var(--color-muted)] focus:outline-none focus:ring-2 focus:ring-[var(--color-accent)]/50"
            />
          </div>

          {!isConfigured && (
            <p className="mt-3 text-xs text-[var(--color-muted)]">
              Jamendo client ID is not configured yet, so search shows sample tracks and filters them locally.
              Add{' '}
              <code className="bg-[var(--color-surface)] px-1 rounded text-[var(--color-accent)]">VITE_JAMENDO_CLIENT_ID</code>{' '}
              in Settings to enable live search.
            </p>
          )}

          {error && (
            <p className="mt-4 text-sm text-red-400 bg-red-950/30 border border-red-900/40 rounded-xl px-4 py-3">
              {error}
            </p>
          )}

          {loading && (
            <div className="mt-6 flex items-center justify-center gap-2 text-sm text-[var(--color-muted)]">
              <Loader2 className="w-4 h-4 animate-spin" />
              Searching Jamendo…
            </div>
          )}

          {results.length > 0 && (
            <div className="mt-6 space-y-2">
              {results.map((track) => (
                <motion.button
                  key={track.id}
                  type="button"
                  onClick={() => playTrack(track)}
                  initial={{ opacity: 0, x: -8 }}
                  animate={{ opacity: 1, x: 0 }}
                  className="w-full text-left surface rounded-xl border border-transparent px-4 py-3 flex items-center gap-3 transition hover:border-[var(--color-accent)]/20"
                >
                  <div className="h-12 w-12 rounded overflow-hidden bg-[var(--color-muted)]/30 shrink-0 flex items-center justify-center text-xs">
                    <span className="opacity-60">♫</span>
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-medium truncate">{track.title}</p>
                    <p className="text-xs text-[var(--color-muted)] truncate">
                      {track.artist}
                      {track.artistUrl ? (
                        <a
                          href={track.artistUrl}
                          target="_blank"
                          rel="noopener"
                          className="ml-1 underline underline-offset-2 hover:text-[var(--color-accent)]"
                        >
                          <ExternalLink className="inline w-3 h-3 align-middle" />
                        </a>
                      ) : null}
                      {track.album ? ` · ${track.album}` : ''}
                    </p>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="text-xs text-[var(--color-muted)]">{track.source}</span>
                      {track.license && (
                        <span className="text-xs px-1.5 py-0.5 rounded-full bg-[var(--color-accent)]/15 text-[var(--color-accent)] capitalize">
                          {track.license}
                        </span>
                      )}
                    </div>
                  </div>
                  <div className="flex items-center gap-1 shrink-0">
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        toggleLike(track.id);
                      }}
                      className={`flex items-center gap-1 text-xs px-2 py-0.5 rounded-full transition ${
                        liked.has(track.id)
                          ? 'bg-[var(--color-accent)]/15 text-[var(--color-accent)]'
                          : 'bg-[var(--color-surface)] text-[var(--color-muted)] hover:text-[var(--color-text)]'
                      }`}
                    >
                      <Heart className={`w-3 h-3 ${liked.has(track.id) ? 'fill-current' : ''}`} />
                      {liked.has(track.id) ? 'Liked' : 'Like'}
                    </button>
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        const name = window.prompt('Playlist name') || 'New playlist';
                        createPlaylist(name);
                      }}
                      className="text-xs px-2 py-0.5 rounded-full bg-[var(--color-surface)] text-[var(--color-muted)] hover:text-[var(--color-text)] transition flex items-center gap-1"
                    >
                      <Plus className="w-3 h-3" />
                      Playlist
                    </button>
                  </div>
                </motion.button>
              ))}
            </div>
          )}

          {query && results.length === 0 && (
            <p className="mt-6 text-sm text-[var(--color-muted)]">No results for “{query}”</p>
          )}
        </motion.div>
      </section>
    </div>
  );
}
