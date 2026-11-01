import { openDB, type DBSchema, type IDBPDatabase } from 'idb';
import type { CacheEntry, Playlist, Track } from '../types';

const DB_NAME = 'manatsume-cache';
const DB_VERSION = 2;

interface ManatsumeDB extends DBSchema {
  assets: {
    key: string;
    value: CacheEntry;
    indexes: { byUpdatedAt: number };
  };
}

let dbPromise: Promise<IDBPDatabase<ManatsumeDB>> | null = null;

function getDB(): Promise<IDBPDatabase<ManatsumeDB>> {
  if (dbPromise) return dbPromise;
  dbPromise = openDB<ManatsumeDB>(DB_NAME, DB_VERSION, {
    upgrade(db) {
      if (!db.objectStoreNames.contains('assets')) {
        const store = db.createObjectStore('assets', { keyPath: 'key' });
        store.createIndex('byUpdatedAt', 'updatedAt');
      }
    },
  });
  return dbPromise;
}

function now(): number {
  // Stable-ish high-resolution timestamp for cache ordering.
  return performance?.now?.() ?? Date.now();
}

export async function cacheAsset(
  key: string,
  blob: Blob,
  contentType?: string,
): Promise<void> {
  const db = await getDB();
  await db.put('assets', { key, blob, updatedAt: now(), contentType });
}

export async function getCachedAsset(key: string): Promise<Blob | null> {
  const db = await getDB();
  const entry = await db.get('assets', key);
  return entry?.blob ?? null;
}

export async function removeCachedAsset(key: string): Promise<void> {
  const db = await getDB();
  await db.delete('assets', key);
}

export async function evictOldestIfNeeded(bytesNeeded: number): Promise<void> {
  const db = await getDB();
  const space = await navigator.storage?.estimate?.();
  const used = space?.usage ?? 0;
  if (used + bytesNeeded <= (space?.quota ?? Infinity)) return;

  // Evict oldest assets until we have room.
  const tx = db.transaction('assets', 'readwrite');
  const index = tx.store.index('byUpdatedAt');
  const cursor = await index.openCursor(null, 'next');
  let remaining = used + bytesNeeded > (space?.quota ?? Infinity) ? used + bytesNeeded : 0;
  try {
    while (cursor && remaining > (space?.quota ?? Infinity)) {
      const entry = cursor.value;
      await cursor.delete();
      remaining -= entry.blob.size;
      cursor.advance(1);
    }
  } finally {
    await tx.done;
  }
}

export async function clearCachedAssets(): Promise<void> {
  const db = await getDB();
  await db.clear('assets');
}

export function likedKey(userId: string): string {
  return `liked:${userId}`;
}

export function playlistsKey(userId: string): string {
  return `playlists:${userId}`;
}

export function queueKey(userId: string): string {
  return `queue:${userId}`;
}

export function loadLikedTrackIds(userId: string): Set<string> {
  try {
    const raw = localStorage.getItem(likedKey(userId));
    if (!raw) return new Set();
    const ids: string[] = JSON.parse(raw);
    return new Set(ids);
  } catch {
    return new Set();
  }
}

export function saveLikedTrackIds(userId: string, ids: Set<string>): void {
  try {
    localStorage.setItem(likedKey(userId), JSON.stringify(Array.from(ids)));
  } catch {
    // storage quota errors are acceptable here
  }
}

export function loadPlaylists(userId: string): Playlist[] {
  try {
    const raw = localStorage.getItem(playlistsKey(userId));
    if (!raw) return [];
    return JSON.parse(raw) as Playlist[];
  } catch {
    return [];
  }
}

export function savePlaylists(userId: string, playlists: Playlist[]): void {
  try {
    localStorage.setItem(playlistsKey(userId), JSON.stringify(playlists));
  } catch {
    // storage quota errors are acceptable here
  }
}

export function loadQueue(userId: string): Track[] {
  try {
    const raw = localStorage.getItem(queueKey(userId));
    if (!raw) return [];
    return JSON.parse(raw) as Track[];
  } catch {
    return [];
  }
}

export function saveQueue(userId: string, queue: Track[]): void {
  try {
    localStorage.setItem(queueKey(userId), JSON.stringify(queue));
  } catch {
    // storage quota errors are acceptable here
  }
}
