import { Link } from 'react-router-dom';

export default function Logo({ href = '/' }: { href?: string }) {
  return (
    <Link
      to={href}
      className="inline-flex items-center gap-2.5 text-lg font-semibold tracking-tight hover:opacity-90 transition"
    >
      <svg
        className="w-6 h-6"
        viewBox="0 0 64 64"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        aria-hidden="true"
      >
        <rect width="64" height="64" rx="14" fill="var(--color-bg)" />
        <g
          fill="none"
          stroke="var(--color-fox-ear)"
          strokeWidth="2.4"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d="M18 26 L26 16 L30 26" />
          <path d="M46 26 L38 16 L34 26" />
        </g>
        <path
          d="M14 34 Q24 22 32 22 Q40 22 50 34"
          fill="none"
          stroke="var(--color-fox-fur)"
          strokeWidth="2.6"
          strokeLinecap="round"
        />
        <circle cx="24" cy="32" r="1.6" fill="var(--color-fox-fur)" />
        <circle cx="40" cy="32" r="1.6" fill="var(--color-fox-fur)" />
        <path
          d="M27 36 L37 36"
          stroke="var(--color-fox-eye)"
          strokeWidth="1.6"
          strokeLinecap="round"
        />
        <path
          d="M42 38 Q46 42 44 47"
          fill="none"
          stroke="var(--color-fox-ear)"
          strokeWidth="2"
          strokeLinecap="round"
        />
      </svg>
      <span>Manatsume</span>
    </Link>
  );
}
