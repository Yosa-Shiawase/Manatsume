import type { Track } from '../types';

export interface PlayerState {
  queue: Track[];
  index: number;
  shuffle: boolean;
  repeat: 'off' | 'one' | 'all';
  current: Track | null;
  playing: boolean;
  volume: number;
  crossfadeMs: number;
  currentTime: number;
  duration: number;
  buffered: number;
}

type Listener = (state: PlayerState) => void;

export class PlayerController {
  private audio: HTMLAudioElement | null = null;
  private _state: PlayerState = {
    queue: [],
    index: 0,
    shuffle: false,
    repeat: 'off',
    current: null,
    playing: false,
    volume: 0.8,
    crossfadeMs: 0,
    currentTime: 0,
    duration: 0,
    buffered: 0,
  };
  private listeners = new Set<Listener>();
  private guardPending = false;

  destroy() {
    this.detach();
  }

  attach(el: HTMLAudioElement | null) {
    if (this.audio === el) return;
    this.detach();
    this.audio = el;
    this.syncAudioEvents();
    if (el) {
      el.volume = this._state.volume;
    }
  }

  private detach() {
    const el = this.audio;
    if (!el) return;
    el.removeEventListener('timeupdate', this.onTimeUpdate);
    el.removeEventListener('loadedmetadata', this.onLoadedMetadata);
    el.removeEventListener('durationchange', this.onDurationChange);
    el.removeEventListener('ended', this.onEnded);
    el.removeEventListener('play', this.onPlay);
    el.removeEventListener('pause', this.onPause);
    el.removeEventListener('waiting', this.onWaiting);
    el.removeEventListener('canplay', this.onCanPlay);
    el.removeEventListener('error', this.onError);
    this.audio = null;
  }

  private syncAudioEvents() {
    const el = this.audio;
    if (!el) return;
    el.addEventListener('timeupdate', this.onTimeUpdate);
    el.addEventListener('loadedmetadata', this.onLoadedMetadata);
    el.addEventListener('durationchange', this.onDurationChange);
    el.addEventListener('ended', this.onEnded);
    el.addEventListener('play', this.onPlay);
    el.addEventListener('pause', this.onPause);
    el.addEventListener('waiting', this.onWaiting);
    el.addEventListener('canplay', this.onCanPlay);
    el.addEventListener('error', this.onError);
  }

  private readonly onTimeUpdate = () => {
    const el = this.audio;
    if (!el) return;
    const buffered =
      el.buffered.length > 0
        ? el.buffered.end(el.buffered.length - 1)
        : 0;
    this.setState({ currentTime: el.currentTime, buffered });
  };

  private readonly onLoadedMetadata = () => {
    const el = this.audio;
    if (!el) return;
    this.setState({ duration: el.duration || 0 });
  };

  private readonly onDurationChange = () => {
    const el = this.audio;
    if (!el) return;
    this.setState({ duration: el.duration || 0 });
  };

  private readonly onEnded = () => {
    this.next();
  };

  private readonly onPlay = () => this.setState({ playing: true });
  private readonly onPause = () => this.setState({ playing: false });
  private readonly onWaiting = () => this.setState({ playing: false });
  private readonly onCanPlay = () => {
    const el = this.audio;
    if (!el) return;
    try {
      el.play();
    } catch {
      // ignore autoplay blocks
    }
  };

  private readonly onError = () => {
    this.setState({ playing: false });
  };

  subscribe(fn: Listener) {
    this.listeners.add(fn);
    fn(this._state);
    return () => this.listeners.delete(fn);
  }

  get state(): Readonly<PlayerState> {
    return this._state;
  }

  private setState(partial: Partial<PlayerState>) {
    this._state = { ...this._state, ...partial };
    for (const fn of this.listeners) {
      fn(this._state);
    }
  }

  setQueue(tracks: Track[]) {
    const prev = this._state;
    this._state.queue = tracks;
    if (tracks.length === 0) {
      this.setState({
        queue: [],
        index: 0,
        current: null,
        duration: 0,
        currentTime: 0,
        buffered: 0,
        playing: false,
      });
      this.stop();
      return;
    }

    const currentId = prev.current?.id;
    let start = 0;
    if (currentId) {
      const idx = tracks.findIndex((t) => t.id === currentId);
      if (idx >= 0) start = idx;
    }

    this.setState({ queue: tracks, index: start, current: tracks[start] });
    this.seekToIndex(start);
  }

  setIndex(i: number) {
    const q = this._state.queue;
    if (!q.length) return;
    const idx = ((i % q.length) + q.length) % q.length;
    this.setState({ index: idx, current: q[idx] });
    this.seekToIndex(idx);
  }

  private seekToIndex(idx: number) {
    const track = this._state.queue[idx];
    if (!track || !this.audio) return;
    this.audio.src = track.url ?? '';
    this.audio.load();
  }

  play() {
    const el = this.audio;
    if (!el) return;
    el.volume = this._state.volume;
    el.play().catch(() => {});
  }

  pause() {
    this.audio?.pause();
  }

  togglePlay() {
    const el = this.audio;
    if (!el) return;
    if (el.paused) {
      el.play().catch(() => {});
    } else {
      el.pause();
    }
  }

  seekTo(t: number) {
    const el = this.audio;
    if (!el) return;
    const max = this._state.duration || 0;
    el.currentTime = Math.max(0, Math.min(t, max));
  }

  setVolume(v: number) {
    this._state.volume = Math.max(0, Math.min(1, v));
    if (this.audio) {
      this.audio.volume = this._state.volume;
    }
    this.setState({});
  }

  setCrossfade(ms: number) {
    this._state.crossfadeMs = Math.max(0, ms);
    this.setState({});
  }

  toggleShuffle() {
    this._state.shuffle = !this._state.shuffle;
    this.setState({});
  }

  toggleRepeat() {
    const modes: Array<'off' | 'one' | 'all'> = ['off', 'one', 'all'];
    const i = modes.indexOf(this._state.repeat);
    const next = modes[(i + 1) % modes.length]!;
    this._state.repeat = next;
    this.setState({});
  }

  next() {
    if (this.guardPending) return;
    this.guardPending = true;
    try {
      this.doNext();
    } finally {
      this.guardPending = false;
    }
  }

  private doNext() {
    const q = this._state.queue;
    if (!q.length) return;

    let nextIndex: number;
    if (this._state.repeat === 'one') {
      nextIndex = this._state.index;
    } else {
      let offset = 1;
      if (this._state.shuffle) {
        const pool = q
          .map((_, i) => i)
          .filter((i) => i !== this._state.index);
        if (pool.length) {
          const pick =
            pool[Math.floor(Math.random() * pool.length)]!;
          nextIndex = pick;
          offset = 0;
        } else {
          nextIndex = this._state.index;
        }
      } else {
        nextIndex = this._state.index + offset;
      }

      if (nextIndex >= q.length) {
        if (this._state.repeat === 'all') {
          nextIndex = 0;
        } else {
          this.pause();
          this.setState({ current: null, playing: false });
          return;
        }
      }
    }

    const nextTrack = q[nextIndex]!;
    this.setState({ index: nextIndex, current: nextTrack, playing: true });
    this.seekToIndex(nextIndex);
  }

  prev() {
    const q = this._state.queue;
    if (!q.length) return;
    const p = this._state.currentTime;
    if (p > 3) {
      this.seekTo(0);
      return;
    }
    const prevIndex = (this._state.index - 1 + q.length) % q.length;
    this.setState({ index: prevIndex, current: q[prevIndex] });
    this.seekToIndex(prevIndex);
  }

  stop() {
    this.audio?.pause();
    if (this.audio) {
      this.audio.src = '';
    }
  }
}
