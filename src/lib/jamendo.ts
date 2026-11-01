export const JAMENDO_API = 'https://api.jamendo.com/v3.0';
export const JAMENDO_CLIENT_ID = import.meta.env.VITE_JAMENDO_CLIENT_ID ?? '';

export interface JamSearchResult {
  id: string;
  title: string;
  artist_name: string;
  album_name?: string;
  duration: number;
  album_image?: string;
  license: string;
  link: string;
  stream?: string;
  audio?: string;
}

export function jamSearchUrl(
  clientId: string = JAMENDO_CLIENT_ID,
  query: string,
  limit = 25,
  offset = 0
): string {
  if (!clientId) throw new Error('JAMENDO_CLIENT_ID is not configured');
  const params = new URLSearchParams({
    client_id: clientId,
    format: 'json',
    search: query,
    include: 'licensename,album_image,stream',
    limit: String(limit),
    offset: String(offset),
    order: 'random',
  });
  return `${JAMENDO_API}/tracks?${params}`;
}

export function jamArtistUrl(clientId: string = JAMENDO_CLIENT_ID, name: string): string {
  if (!clientId) throw new Error('JAMENDO_CLIENT_ID is not configured');
  const params = new URLSearchParams({
    client_id: clientId,
    format: 'json',
    name: name,
    include: 'image',
    limit: '1',
  });
  return `${JAMENDO_API}/artists?${params}`;
}
