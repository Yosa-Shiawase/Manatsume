import { useRef, useEffect, useCallback } from 'react';
import { Play, Pause, SkipBack, SkipForward, Volume2, Repeat, Shuffle, Heart, Download } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { PlayerController } from '../lib/player';
import type { Track } from '../types';
import { loadQueue, saveQueue, loadLikedTrackIds, saveLikedTrackIds } from '../lib/cache';
import TopNav from '../components/TopNav';

export default function PlayerPage() {
  const navigate = useNavigate();
  void navigate;
  const controllerRef = useRef<PlayerController | null>(null);
  const { user } = useAuth();

  const localQueue = user ? loadQueue(user.id) : [];
  const localLiked = user ? loadLikedTrackIds(user.id) : new Set<string>();

  useEffect(() => {
    const audio = document.getElementById('manatsume-audio') as HTMLAudioElement | null;
    if (!audio) return;
    const controller = new PlayerController();
    controller.attach(audio);
    controllerRef.current = controller;

    return () => {
      controller.destroy();
    };
  }, []);

  useEffect(() => {
    const controller = controllerRef.current;
    if (!controller) return;

    let queue: Track[] = [];
    let preselectedId: string | null = null;

    const replay = (window.history.state as { replay?: { V?: { track?: Track; queue?: Track[] } } } | null)?.replay?.V;
    if (replay?.queue && replay.queue.length) {
      queue = replay.queue;
      if (replay.track) preselectedId = replay.track.id;
    } else if (user && localQueue.length) {
      queue = localQueue;
      if (localQueue.length === 1) preselectedId = localQueue[0]!.id;
    }

    controller.setQueue(queue);

    if (preselectedId) {
      const idx = queue.findIndex((t) => t.id === preselectedId);
      if (idx >= 0) controller.setIndex(idx);
    }

    const unsub = controller.subscribe((s) => {
      if (user && s.queue.length) {
        saveQueue(user.id, s.queue);
      }
    });
    return () => {
      unsub();
    };
  }, [user, localQueue]);

  const playing = controllerRef.current?.state.playing ?? false;
  const current = controllerRef.current?.state.current ?? null;
  const queue = controllerRef.current?.state.queue ?? [];
  const index = controllerRef.current?.state.index ?? 0;
  const shuffle = controllerRef.current?.state.shuffle ?? false;
  const repeat = controllerRef.current?.state.repeat ?? 'off';
  const volume = controllerRef.current?.state.volume ?? 0.8;
  const currentTime = controllerRef.current?.state.currentTime ?? 0;
  const duration = controllerRef.current?.state.duration ?? 0;
  const buffered = controllerRef.current?.state.buffered ?? 0;
  const liked = user ? loadLikedTrackIds(user.id) : localLiked;

  const togglePlay = useCallback(() => {
    controllerRef.current?.togglePlay();
  }, []);

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

  const downloadTrack = useCallback(
    (track: Track) => {
      const src = track.url;
      if (!src) {
        alert(
          `"${track.title}" by ${track.artist} is in the Jamendo catalog. The app streams it in the player; a direct download is not available unless the track provides one.`,
        );
        return;
      }
      fetch(src)
        .then((r) => r.blob())
        .then((blob) => {
          const url = URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.href = url;
          a.download = `${track.title}.mp3`;
          a.click();
          setTimeout(() => URL.revokeObjectURL(url), 1000);
        })
        .catch(() => {
          alert('Could not download that track right now.');
        });
    },
    [],
  );

  const progress = duration > 0 ? (currentTime / duration) * 100 : 0;
  const bufferedPct = duration > 0 ? (buffered / duration) * 100 : 0;

  const next = useCallback(() => controllerRef.current?.next(), []);
  const prev = useCallback(() => controllerRef.current?.prev(), []);
  const seek = useCallback((t: number) => controllerRef.current?.seekTo(t), []);
  const setVolume = useCallback((v: number) => controllerRef.current?.setVolume(v), []);
  const toggleShuffle = useCallback(() => controllerRef.current?.toggleShuffle(), []);
  const toggleRepeat = useCallback(() => controllerRef.current?.toggleRepeat(), []);

  return (
    <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans selection:bg-[var(--color-accent)]/30 pb-24">
      <audio
        id="manatsume-audio"
        className="hidden"
        preload="metadata"
        src={current?.url ?? ''}
      />

      <TopNav />

      <div className="max-w-5xl mx-auto px-5 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
          <div className="lg:col-span-3 space-y-6">
            <div className="relative rounded-2xl overflow-hidden aspect-square bg-[var(--color-surface)] border border-[var(--color-border)] shadow-2xl">
              {current?.artwork ? (
                <img
                  src={current.artwork}
                  alt={current.title}
                  className={`w-full h-full object-cover transition duration-700 ${playing ? 'scale-100' : 'scale-105'}`}
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-[var(--color-muted)] text-6xl">
                  <span>♫</span>
                </div>
              )}
              <div className="absolute inset-0 bg-gradient-to-t from-[var(--color-bg)]/60 to-transparent" />
              {current?.license && (
                <div className="absolute top-3 right-3 text-xs px-2 py-1 rounded-full bg-[var(--color-accent)]/15 text-[var(--color-accent)]">
                  {current.license}
                </div>
              )}
              {current?.artistUrl && (
                <a
                  href={current.artistUrl}
                  target="_blank"
                  rel="noopener"
                  className="absolute top-3 left-3 text-xs px-2 py-1 rounded-full bg-[var(--color-surface)] text-[var(--color-muted)] hover:text-[var(--color-text)] transition flex items-center gap-1"
                >
                  Artist
                </a>
              )}
            </div>

            <div>
              <p className="text-xs uppercase tracking-widest text-[var(--color-muted)] mb-1">Now playing</p>
              <h2 className="text-2xl font-semibold">{current?.title ?? '—'}</h2>
              <p className="text-[var(--color-muted)] mt-1">{current?.artist ?? '—'}</p>
              {current?.album && <p className="text-xs text-[var(--color-muted)] mt-1">{current.album}</p>}
              <div className="flex items-center gap-2 mt-2">
                <button
                  type="button"
                  onClick={() => toggleLike(current?.id ?? '')}
                  className={`flex items-center gap-1 text-xs px-2 py-0.5 rounded-full transition ${
                    liked.has(current?.id ?? '')
                      ? 'bg-[var(--color-accent)]/15 text-[var(--color-accent)]'
                      : 'bg-[var(--color-surface)] text-[var(--color-muted)] hover:text-[var(--color-text)]'
                  }`}
                >
                  <Heart className={`w-3 h-3 ${liked.has(current?.id ?? '') ? 'fill-current' : ''}`} />
                  {liked.has(current?.id ?? '') ? 'Liked' : 'Like'}
                </button>
                <button
                  type="button"
                  onClick={() => current && downloadTrack(current)}
                  className="flex items-center gap-1 text-xs px-2 py-0.5 rounded-full bg-[var(--color-surface)] text-[var(--color-muted)] hover:text-[var(--color-text)] transition"
                >
                  <Download className="w-3 h-3" />
                  Download
                </button>
                <span className="text-xs text-[var(--color-muted)]">{current?.source ?? ''}</span>
              </div>
            </div>

            <div>
              <div className="flex justify-between text-xs text-[var(--color-muted)] mb-1">
                <span>{Math.round(currentTime)}s</span>
                <span>{Math.round(duration)}s</span>
              </div>
              <div className="relative h-1 rounded-full bg-[var(--color-border)]">
                {bufferedPct > 0 && (
                  <div
                    className="absolute inset-y-0 left-0 w-[1px] bg-[var(--color-surface)]"
                    style={{ width: `${bufferedPct}%` }}
                  />
                )}
                <input
                  type="range"
                  min={0}
                  max={duration || 100}
                  step={0.1}
                  value={currentTime}
                  onChange={(e) => seek(parseFloat(e.target.value))}
                  className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                  style={{ pointerEvents: 'auto' }}
                />
                <div
                  className="absolute inset-y-0 left-0 w-1 bg-[var(--color-accent)] rounded-full"
                  style={{ width: `${progress}%` }}
                />
              </div>
            </div>

            <div className="flex items-center justify-center gap-4">
              <button
                type="button"
                onClick={toggleShuffle}
                className={`surface p-2 transition ${shuffle ? 'text-[var(--color-accent)]' : 'text-[var(--color-muted)] hover:text-[var(--color-text)]'}`}
                aria-label="Shuffle"
              >
                <Shuffle className="w-4 h-4" />
              </button>
              <button type="button" onClick={prev} className="surface p-2" aria-label="Previous">
                <SkipBack className="w-5 h-5" />
              </button>
              <button
                type="button"
                onClick={togglePlay}
                className="w-12 h-12 rounded-full bg-[var(--color-accent)] text-[var(--color-bg)] flex items-center justify-center transition hover:brightness-110 active:scale-95"
                aria-label={playing ? 'Pause' : 'Play'}
              >
                {playing ? <Pause className="w-5 h-5" /> : <Play className="w-5 h-5" />}
              </button>
              <button type="button" onClick={next} className="surface p-2" aria-label="Next">
                <SkipForward className="w-5 h-5" />
              </button>
              <button
                type="button"
                onClick={toggleRepeat}
                className={`surface p-2 transition ${repeat !== 'off' ? 'text-[var(--color-accent)]' : 'text-[var(--color-muted)] hover:text-[var(--color-text)]'}`}
                aria-label="Repeat"
              >
                <Repeat className="w-4 h-4" />
              </button>
            </div>

            <div className="flex items-center gap-3">
              <Volume2 className="w-4 h-4 text-[var(--color-muted)]" />
              <input
                type="range"
                min={0}
                max={1}
                step={0.01}
                value={volume}
                onChange={(e) => setVolume(parseFloat(e.target.value))}
                className="flex-1 h-1 rounded-full appearance-none bg-[var(--color-border)] cursor-pointer"
                style={{
                  background: `linear-gradient(to right, var(--color-accent) 0%, var(--color-accent) ${volume * 100}%, var(--color-border) ${volume * 100}%, var(--color-border) 100%)`,
                }}
              />
              <span className="text-xs text-[var(--color-muted)] w-8 text-right">
                {Math.round(volume * 100)}%
              </span>
            </div>

            <div className="flex items-center gap-3 text-xs text-[var(--color-muted)]">
              <span className="flex items-center gap-1">
                <span className="h-2 w-2 rounded-full bg-[var(--color-accent)]/50 animate-pulse" />
                {shuffle ? 'shuffle' : repeat !== 'off' ? repeat : 'playing'}
              </span>
            </div>
          </div>

          <aside className="lg:col-span-2">
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-sm font-medium">Queue</h3>
              <span className="text-xs text-[var(--color-muted)]">{queue.length} track{queue.length === 1 ? '' : 's'}</span>
            </div>
            <div className="space-y-2">
              {queue.map((track, i) => (
                <button
                  key={track.id}
                  type="button"
                  onClick={() => {
                    controllerRef.current?.setIndex(i);
                    controllerRef.current?.play();
                  }}
                  className={`w-full text-left surface rounded-xl border border-transparent px-4 py-3 flex items-center gap-3 transition hover:border-[var(--color-accent)]/20 ${
                    i === index ? 'border-[var(--color-accent)]/30 bg-[var(--color-accent)]/10' : ''
                  }`}
                >
                  <div className="h-10 w-10 rounded overflow-hidden bg-[var(--color-muted)]/30 shrink-0 flex items-center justify-center text-xs">
                    {track.artwork ? (
                      <img src={track.artwork} alt="" className="h-full w-full object-cover" loading="lazy" />
                    ) : (
                      <span className="opacity-60">♫</span>
                    )}
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-medium truncate">{track.title}</p>
                    <p className="text-xs text-[var(--color-muted)] truncate">{track.artist}</p>
                  </div>
                  {i === index && playing && (
                    <span className="text-xs text-[var(--color-accent)] shrink-0">playing</span>
                  )}
                </button>
              ))}
              {queue.length === 0 && (
                <p className="text-xs text-[var(--color-muted)] py-4 text-center">
                  Queue is empty. Search for music or go to your library.
                </p>
              )}
            </div>

            <div className="mt-6 flex items-center gap-2 text-xs text-[var(--color-muted)]">
              <span className="h-2 w-2 rounded-full bg-[var(--color-accent)]/50 animate-pulse shrink-0" />
              Audio is streamed from the source URL when available.
            </div>
          </aside>
        </div>
      </div>
    </div>
  );
}
