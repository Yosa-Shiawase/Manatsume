import { Link, useLocation } from 'react-router-dom';
import Logo from './Logo';

const NAV = [
  { to: '/', label: 'Home' },
  { to: '/search', label: 'Search' },
  { to: '/library', label: 'Library' },
];

const BOTTOM_ACTIONS = [
  { to: '/settings', label: 'Settings' },
  { to: '/player', label: 'Player' },
];

export default function TopNav() {
  const location = useLocation();
  const onPlayerPath = location.pathname === '/player';

  return (
    <header className="sticky top-0 z-30 flex items-center justify-between px-5 py-3 border-b border-[var(--color-border)] bg-[var(--color-bg)]/80 backdrop-blur-sm">
      <div className="flex items-center gap-3">
        <Logo />
        <nav className="hidden md:flex items-center gap-4 text-sm text-[var(--color-muted)] ml-6">
          {NAV.map((n) => (
            <Link
              key={n.to}
              to={n.to}
              className={`transition ${location.pathname === n.to ? 'text-[var(--color-text)]' : 'hover:text-[var(--color-text)]'}`}
            >
              {n.label}
            </Link>
          ))}
        </nav>
      </div>
      <div className="flex items-center gap-1">
        {BOTTOM_ACTIONS.map((a) => (
          <Link
            key={a.to}
            to={a.to}
            className={`px-3 py-1.5 rounded-full text-xs border transition flex items-center gap-1.5 ${
              (onPlayerPath && a.to === '/player') || a.to === '/settings'
                ? 'border-[var(--color-accent)]/50 bg-[var(--color-accent)]/10 text-[var(--color-accent)]'
                : 'border-[var(--color-border)] bg-[var(--color-surface)] hover:border-[var(--color-accent)]/50 text-[var(--color-muted)]'
            }`}
          >
            {a.label}
          </Link>
        ))}
      </div>
    </header>
  );
}
