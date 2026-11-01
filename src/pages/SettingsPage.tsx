import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { Settings as SettingsIcon, Link as LinkIcon, Check, AlertCircle, ExternalLink } from 'lucide-react';
import TopNav from '../components/TopNav';

const STORAGE_KEY = 'manatsume.jamendoClientId';

export default function SettingsPage() {
  const [clientId, setClientId] = useState('');
  const [saved, setSaved] = useState(false);
  const [status, setStatus] = useState<'ready' | 'saved' | 'error'>('ready');

  useEffect(() => {
    try {
      const existing = localStorage.getItem(STORAGE_KEY);
      if (existing) setClientId(existing);
    } catch {
      // ignore
    }
  }, []);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (!clientId.trim()) {
      setStatus('error');
      return;
    }
    try {
      localStorage.setItem(STORAGE_KEY, clientId.trim());
      setStatus('saved');
      setSaved(true);
    } catch {
      setStatus('error');
    }
  };

  const isLive =
    typeof import.meta !== 'undefined' &&
    Boolean(import.meta.env?.VITE_JAMENDO_CLIENT_ID) &&
    clientId.trim();

  return (
    <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans selection:bg-[var(--color-accent)]/30">
      <TopNav />
      <section className="max-w-2xl mx-auto px-5 py-12">
        <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }}>
          <button
            type="button"
            onClick={() => (window.location.href = '/')}
            className="flex items-center gap-1 text-sm text-[var(--color-muted)] hover:text-[var(--color-text)] mb-6"
          >
            <LinkIcon className="w-4 h-4" />
            Back
          </button>
          <h1 className="text-3xl font-semibold mb-2">Settings</h1>
          <p className="text-[var(--color-muted)] mb-6">Configure your music sources and account.</p>
        </motion.div>

        <div className="space-y-6">
          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="surface rounded-xl border border-[var(--color-border)] p-5"
          >
            <div className="flex items-center gap-2 mb-4">
              <SettingsIcon className="w-5 h-5 text-[var(--color-accent)]" />
              <h2 className="text-sm font-medium">Jamendo client ID</h2>
            </div>

            <p className="text-xs text-[var(--color-muted)] mb-4 leading-relaxed">
              To search the live Jamendo catalog, paste your Jamendo API client ID here. You can get one at
              the{' '}
              <a
                href="https://developer.jamendo.com/"
                target="_blank"
                rel="noopener"
                className="underline hover:text-[var(--color-text)]"
              >
                Jamendo developer portal
                <ExternalLink className="inline w-3 h-3 ml-0.5" />
              </a>
              . This app uses the Jamendo catalog under a non-commercial API plan and streams tracks from the
              source links the API provides.
            </p>

            {isLive ? (
              <div className="flex items-center gap-2 text-xs text-[var(--color-accent)] mb-4">
                <Check className="w-4 h-4" />
                Live search is enabled.
              </div>
            ) : (
              <div className="flex items-center gap-2 text-xs text-[var(--color-muted)] mb-4">
                <AlertCircle className="w-4 h-4" />
                Live search is disabled. Set a client ID above to enable it.
              </div>
            )}

            <form onSubmit={handleSave} className="space-y-3">
              <div>
                <label className="block text-xs font-medium mb-1 text-[var(--color-muted)]">
                  Client ID
                </label>
                <input
                  type="text"
                  value={clientId}
                  onChange={(e) => setClientId(e.target.value)}
                  placeholder="paste your Jamendo client_id"
                  className="w-full h-12 px-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] text-[var(--color-text)] placeholder-[var(--color-muted)] focus:outline-none focus:ring-2 focus:ring-[var(--color-accent)]/50 font-mono text-sm"
                />
              </div>
              <div className="flex items-center gap-3">
                <button
                  type="submit"
                  className="bg-[var(--color-accent)] text-[var(--color-bg)] font-medium px-5 py-2 rounded-xl hover:brightness-110 transition text-sm"
                >
                  Save client ID
                </button>
                {saved && (
                  <span className="text-xs text-[var(--color-accent)]">Saved locally.</span>
                )}
                {status === 'error' && (
                  <span className="text-xs text-red-400">Could not save. Try again.</span>
                )}
              </div>
            </form>

            <p className="mt-4 text-xs text-[var(--color-muted)] leading-relaxed">
              This setting is stored only on your device. If you set{' '}
              <code className="bg-[var(--color-surface)] px-1 rounded text-[var(--color-accent)]">VITE_JAMENDO_CLIENT_ID</code>{' '}
              in your deployment environment, that value is used first.
            </p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="surface rounded-xl border border-[var(--color-border)] p-5"
          >
            <div className="flex items-center gap-2 mb-4">
              <LinkIcon className="w-5 h-5 text-[var(--color-accent)]" />
              <h2 className="text-sm font-medium">About this app</h2>
            </div>
            <div className="space-y-3 text-xs text-[var(--color-muted)] leading-relaxed">
              <p>
                Manatsume is a free music player with playlists, search, and a calm dark theme. It is
                installable in Chrome and built to run like a small app.
              </p>
              <p>
                Music comes from the Jamendo catalog (under a non-commercial API plan) and from music you add
                yourself. Each track credits its artist and shows its license.
              </p>
              <p>
                Your playlists, likes, and queue are stored on your device and tied to your account.
              </p>
              <div className="flex flex-wrap gap-3 pt-2">
                <Link to="/licenses" className="text-[var(--color-accent)] hover:underline">Licenses</Link>
                <Link to="/privacy" className="text-[var(--color-accent)] hover:underline">Privacy</Link>
                <Link to="/sources" className="text-[var(--color-accent)] hover:underline">Sources</Link>
                <a href="https://www.jamendo.com" target="_blank" rel="noopener" className="text-[var(--color-accent)] hover:underline">
                  Music via Jamendo
                  <ExternalLink className="inline w-3 h-3 ml-0.5" />
                </a>
                <span>MIT</span>
              </div>
            </div>
          </motion.div>
        </div>
      </section>
    </div>
  );
}
