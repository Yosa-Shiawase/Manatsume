export interface User {
  id: string;
  email: string;
  name: string;
}

export interface Playlist {
  id: string;
  userId: string;
  name: string;
  tracks: Track[];
}

export interface LikedTrack {
  userId: string;
  trackId: string;
}

export interface Track {
  id: string;
  title: string;
  artist: string;
  album?: string;
  duration: number;
  artwork?: string;
  source?: string;
  license?: string;
  url?: string;
  /** URL-safe artist credit link, e.g. Jamendo artist page. Filled when source supports it. */
  artistUrl?: string;
}

export interface CacheEntry {
  key: string;
  blob: Blob;
  updatedAt: number;
  contentType?: string;
}

export type RepeatMode = 'off' | 'one' | 'all';
