import { ExternalLink } from 'lucide-react';
import type { Track } from '../types';

interface TrackCardProps {
  track: Track;
  onClick?: () => void;
  showActions?: boolean;
  liked?: boolean;
  onToggleLike?: (id: string) => void;
  onAddToPlaylist?: (track: Track) => void;
  className?: string;
}

export default function TrackCard({
  track,
  onClick,
  showActions = false,
  liked = false,
  onToggleLike,
  onAddToPlaylist,
  className = '',
}: TrackCardProps) {
  return (
    <div
      className={`w-full text-left surface rounded-xl border border-transparent px-4 py-3 transition hover:border-[var(--color-accent)]/20 group ${className}`}
      onClick={onClick}
    >
      <div className="flex items-start gap-3">
        <div className="h-14 w-14 rounded overflow-hidden bg-[var(--color-muted)]/30 shrink-0 flex items-center justify-center text-xs">
          {track.artwork ? (
            <img src={track.artwork} alt="" className="h-full w-full object-cover" loading="lazy" />
          ) : (
            <span className="opacity-60">♫</span>
          )}
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
            <span className="text-xs text-[var(--color-muted)]">{track.source ?? ''}</span>
            {track.license && (
              <span className="text-xs px-1.5 py-0.5 rounded-full bg-[var(--color-accent)]/15 text-[var(--color-accent)] capitalize">
                {track.license}
              </span>
            )}
          </div>
        </div>
      </div>
      {showActions && (
        <div className="flex items-center gap-1 mt-2 shrink-0 opacity-0 group-hover:opacity-100 transition">
          {onToggleLike && (
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                onToggleLike(track.id);
              }}
              className={`flex items-center gap-1 text-xs px-2 py-0.5 rounded-full transition ${
                liked
                  ? 'bg-[var(--color-accent)]/15 text-[var(--color-accent)]'
                  : 'bg-[var(--color-surface)] text-[var(--color-muted)] hover:text-[var(--color-text)]'
              }`}
            >
              <HeartIcon fill={liked ? 'currentColor' : 'none'} />
              {liked ? 'Liked' : 'Like'}
            </button>
          )}
          {onAddToPlaylist && (
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                onAddToPlaylist(track);
              }}
              className="text-xs px-2 py-0.5 rounded-full bg-[var(--color-surface)] text-[var(--color-muted)] hover:text-[var(--color-text)] transition flex items-center gap-1"
            >
              <PlusIcon />
              Playlist
            </button>
          )}
        </div>
      )}
    </div>
  );
}

function HeartIcon({ fill }: { fill?: string }) {
  return (
    <svg className="w-3 h-3" viewBox="0 0 24 24" fill={fill} aria-hidden="true">
      <path d="M12 21s-7.5-4.6-10.5-9C1.5 10.5 2 6 6 6c2 0 3 1 3 1H12v4h6c0 0 1-1 2-2 1.5 4.4 2 8.9 2 13 0 1.1-.5 2-1.5 2z" />
    </svg>
  );
}

function PlusIcon() {
  return (
    <svg className="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <line x1="12" y1="5" x2="12" y2="19" />
      <line x1="5" y1="12" x2="19" y2="12" />
    </svg>
  );
}
