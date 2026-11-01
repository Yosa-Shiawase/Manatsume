import { useState, useCallback, type FormEvent } from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import TopNav from '../components/TopNav';

export default function AuthPage() {
  const { user, signOut, loading, signIn } = useAuth();
  const [email, setEmail] = useState('');
  const [name, setName] = useState('');
  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSignIn = (e: FormEvent) => {
    e.preventDefault();
    setPending(true);
    setError(null);
    try {
      if (!email.trim()) {
        setError('Please enter an email address.');
        return;
      }
      if (!user) {
        signIn(email, name);
      }
    } finally {
      setPending(false);
    }
  };

  const handleSignOut = useCallback(async () => {
    await signOut();
  }, [signOut]);
  void handleSignOut;

  if (loading) {
    return (
      <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans flex items-center justify-center">
        <div className="text-sm text-[var(--color-muted)]">Loading…</div>
      </div>
    );
  }

  if (user) {
    return (
      <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans">
        <TopNav />
        <section className="max-w-md mx-auto px-5 py-16">
          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-6"
          >
            <div className="flex items-center gap-2 text-xs uppercase tracking-widest text-[var(--color-accent)]">
              Signed in
            </div>
            <h1 className="text-3xl font-semibold tracking-tight">Welcome back</h1>
            <p className="text-[var(--color-muted)]">You are signed in as {user.email}.</p>

            <div className="surface rounded-2xl border border-[var(--color-border)] p-6 space-y-4">
              <div className="flex items-center gap-4">
                <div className="h-14 w-14 rounded-full bg-[var(--color-accent)]/15 flex items-center justify-center text-2xl text-[var(--color-accent)]">
                  {user.name.charAt(0).toUpperCase()}
                </div>
                <div>
                  <p className="text-sm font-medium">{user.name}</p>
                  <p className="text-xs text-[var(--color-muted)]">{user.email}</p>
                </div>
              </div>
              <p className="text-xs text-[var(--color-muted)] leading-relaxed">
                Your playlists, likes, and queue are now tied to this account. When Convex Auth is
                provisioned, sign-in here will use the real provider.
              </p>
            </div>

            <div className="text-xs text-[var(--color-muted)] text-center flex flex-wrap justify-center gap-3">
              <Link to="/licenses" className="underline hover:text-[var(--color-text)]">Licenses</Link>
              <a href="https://www.jamendo.com" target="_blank" rel="noopener" className="underline hover:text-[var(--color-text)]">Music via Jamendo</a>
              <span>MIT</span>
            </div>
          </motion.div>
        </section>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans">
      <TopNav />
      <section className="max-w-md mx-auto px-5 py-16 md:py-24">
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          className="space-y-6"
        >
          <div className="flex items-center gap-2 text-xs uppercase tracking-widest text-[var(--color-accent)]">
            Sign in
          </div>
          <h1 className="text-3xl md:text-4xl font-semibold tracking-tight">Welcome back</h1>
          <p className="text-[var(--color-muted)]">
            Sign in to access your playlists, likes, and queue.
          </p>

          <form
            onSubmit={handleSignIn}
            className="surface rounded-2xl border border-[var(--color-border)] p-6 space-y-4"
          >
            {error && (
              <p className="text-sm text-red-400 bg-red-950/30 border border-red-900/40 rounded-xl px-4 py-3">
                {error}
              </p>
            )}
            <div>
              <label className="block text-sm font-medium mb-1">Email</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@example.com"
                autoComplete="email"
                className="w-full h-12 px-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] text-[var(--color-text)] placeholder-[var(--color-muted)] focus:outline-none focus:ring-2 focus:ring-[var(--color-accent)]/50"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Name</label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Your name"
                autoComplete="name"
                className="w-full h-12 px-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] text-[var(--color-text)] placeholder-[var(--color-muted)] focus:outline-none focus:ring-2 focus:ring-[var(--color-accent)]/50"
              />
            </div>
            <button
              type="submit"
              disabled={pending}
              className="w-full bg-[var(--color-accent)] text-[var(--color-bg)] font-medium px-6 py-3 rounded-xl hover:brightness-110 transition disabled:opacity-50"
            >
              {pending ? 'Signing in…' : 'Sign in'}
            </button>
            <p className="text-xs text-[var(--color-muted)] text-center">
              When Convex Auth is provisioned, this page will use the real sign-in flow.
            </p>
          </form>
        </motion.div>
      </section>

      <footer className="border-t border-[var(--color-border)] py-6 text-center text-xs text-[var(--color-muted)]">
        <Link to="/" className="hover:text-[var(--color-text)]">Manatsume</Link>
        {' · '}
        <Link to="/licenses" className="hover:text-[var(--color-text)]">Licenses</Link>
        {' · '}
        <a href="https://www.jamendo.com" target="_blank" rel="noopener" className="hover:text-[var(--color-text)]">Music via Jamendo</a>
        {' · '}
        MIT
      </footer>
    </div>
  );
}
