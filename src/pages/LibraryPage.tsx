import { useState, useCallback } from 'react';
import { motion } from 'framer-motion';
import { ChevronLeft, Heart, Library, Download, Trash2, Plus, Play } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import type { Track } from '../types';
import {
  loadLikedTrackIds,
  saveLikedTrackIds,
  loadPlaylists,
  savePlaylists,
} from '../lib/cache';

export default function LibraryPage() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const liked = user ? loadLikedTrackIds(user.id) : new Set<string>();
  const playlists = user ? loadPlaylists(user.id) : [];
  const [playlistsState, setPlaylistsState] = useState(playlists);

  const toggleLike = useCallback(
    (trackId: string) => {
      if (!user) return;
      const next = new Set(liked);
      if (next.has(trackId)) next.delete(trackId);
      else next.add(trackId);
      saveLikedTrackIds(user.id, next);
    },
    [user, liked],
  );

  const createPlaylist = useCallback(
    (name: string) => {
      if (!user || !name.trim()) return;
      const id = name.toLowerCase().replace(/\s+/g, '-') + '-' + Date.now().toString(36);
      const playlist = { id, userId: user.id, name: name.trim(), tracks: [] as Track[] };
      const updated = [...playlistsState, playlist];
      setPlaylistsState(updated);
      savePlaylists(user.id, updated);
    },
    [user, playlistsState],
  );

  const renamePlaylist = useCallback(
    (playlistId: string, name: string) => {
      if (!user) return;
      const updated = playlistsState.map((p) =>
        p.id === playlistId ? { ...p, name: name.trim() || p.name } : p,
      );
      setPlaylistsState(updated);
      savePlaylists(user.id, updated);
    },
    [user, playlistsState],
  );

  const deletePlaylist = useCallback(
    (playlistId: string) => {
      if (!user) return;
      const updated = playlistsState.filter((p) => p.id !== playlistId);
      setPlaylistsState(updated);
      savePlaylists(user.id, updated);
    },
    [user, playlistsState],
  );

  const demoTracks: Track[] = [
    { id: 't1', title: 'Midnight Signal', artist: 'Long Summer Night', duration: 214, source: 'Jamendo' },
    { id: 't2', title: 'Paper Fox', artist: 'Ink Studio', duration: 188, source: 'Jamendo' },
    { id: 't3', title: 'Static Lullaby', artist: 'Echo Room', duration: 243, source: 'Jamendo' },
    { id: 't4', title: 'Late Night Waves', artist: 'Tidal Haze', duration: 201, source: 'Jamendo' },
    { id: 't5', title: 'Foxglove', artist: 'Ink Garden', duration: 176, source: 'Jamendo' },
  ];

  const back = useCallback(() => {
    navigate('/', { replace: true });
  }, [navigate]);

  return (
    <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans selection:bg-[var(--color-accent)]/30">
      <header className="sticky top-0 z-30 flex items-center justify-between px-5 py-3 border-b border-[var(--color-border)] bg-[var(--color-bg)]/80 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={back}
            className="text-lg font-semibold tracking-tight flex items-center gap-1 hover:text-[var(--color-text)]"
          >
            <ChevronLeft className="w-4 h-4" />
            Manatsume
          </button>
          <nav className="hidden md:flex items-center gap-4 text-sm text-[var(--color-muted)] ml-6">
            <a href="/" className="hover:text-[var(--color-text)]">Home</a>
            <a href="/search" className="hover:text-[var(--color-text)]">Search</a>
            <a href="/player" className="hover:text-[var(--color-text)]">Player</a>
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

      <section className="max-w-3xl mx-auto px-5 py-12">
        <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }}>
          <button
            type="button"
            onClick={back}
            className="flex items-center gap-1 text-sm text-[var(--color-muted)] hover:text-[var(--color-text)] mb-6"
          >
            <ChevronLeft className="w-4 h-4" />
            Back
          </button>
          <h1 className="text-3xl font-semibold mb-2">Your library</h1>
          <p className="text-[var(--color-muted)] mb-6">Your playlists, liked tracks, and uploads.</p>
        </motion.div>

        <div className="space-y-6">
          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="surface rounded-xl border border-[var(--color-border)] p-4"
          >
            <h2 className="text-sm font-medium mb-3 flex items-center gap-2">
              <Heart className="w-4 h-4 text-[var(--color-accent)]" />
              Liked tracks
            </h2>
            {liked.size === 0 ? (
              <p className="text-xs text-[var(--color-muted)]">No liked tracks.</p>
            ) : (
              <div className="space-y-2">
                {demoTracks.filter((t) => liked.has(t.id)).map((track) => (
                  <div key={track.id} className="flex items-center justify-between surface rounded-lg px-3 py-2 border border-[var(--color-border)] text-sm">
                    <div className="min-w-0 flex-1">
                      <p className="font-medium truncate">{track.title}</p>
                      <p className="text-xs text-[var(--color-muted)] truncate">{track.artist}</p>
                    </div>
                    <button
                      type="button"
                      onClick={() => toggleLike(track.id)}
                      className="text-xs text-[var(--color-muted)] hover:text-red-400 transition ml-2"
                    >
                      <Heart className="w-4 h-4 fill-red-400" />
                    </button>
                  </div>
                ))}
              </div>
            )}
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="surface rounded-xl border border-[var(--color-border)] p-4"
          >
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-sm font-medium flex items-center gap-2">
                <Library className="w-4 h-4 text-[var(--color-accent)]" />
                Playlists
              </h2>
              <button
                type="button"
                onClick={() => {
                  const name = window.prompt('Playlist name') || '';
                  createPlaylist(name);
                }}
                className="text-xs px-2 py-1 rounded-full bg-[var(--color-surface)] text-[var(--color-muted)] hover:text-[var(--color-text)] transition flex items-center gap-1"
              >
                <Plus className="w-3 h-3" />
                New playlist
              </button>
            </div>
            {playlistsState.length === 0 ? (
              <p className="text-xs text-[var(--color-muted)]">No playlists yet.</p>
            ) : (
              <div className="space-y-2">
                {playlistsState.map((playlist) => (
                  <div key={playlist.id} className="flex items-center justify-between surface rounded-lg px-3 py-2 border border-[var(--color-border)] text-sm">
                    <div className="min-w-0 flex-1">
                      <p className="font-medium truncate">{playlist.name}</p>
                      <p className="text-xs text-[var(--color-muted)] truncate">{playlist.tracks.length} tracks</p>
                    </div>
                    <div className="flex items-center gap-1">
                      <button
                        type="button"
                        onClick={() => {
                          const name = window.prompt('Rename playlist', playlist.name) || playlist.name;
                          renamePlaylist(playlist.id, name);
                        }}
                        className="text-xs text-[var(--color-muted)] hover:text-[var(--color-text)] transition"
                      >
                        Rename
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          if (confirm(`Delete playlist "${playlist.name}"?`)) {
                            deletePlaylist(playlist.id);
                          }
                        }}
                        className="text-xs text-[var(--color-muted)] hover:text-red-400 transition"
                      >
                        <Trash2 className="w-3 h-3" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="surface rounded-xl border border-[var(--color-border)] p-4"
          >
            <h2 className="text-sm font-medium mb-3 flex items-center gap-2">
              <Download className="w-4 h-4 text-[var(--color-accent)]" />
              Your uploads
            </h2>
            <p className="text-xs text-[var(--color-muted)] mb-3">Upload your own music files here.</p>
            <label className="block surface rounded-lg border-2 border-dashed border-[var(--color-border)] p-4 text-center cursor-pointer hover:border-[var(--color-accent)]/50 transition">
              <input type="file" accept="audio/*" multiple className="hidden" />
              <span className="text-sm text-[var(--color-text)]">Add music files</span>
            </label>
          </motion.div>
        </div>
      </section>
    </div>
  );
}
