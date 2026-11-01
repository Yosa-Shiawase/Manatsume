import React, { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from 'react';

type ThemeId = 'night' | 'nightWarm' | 'paper';

type Theme = {
  id: ThemeId;
  label: string;
  class: string;
};

const THEMES: Record<ThemeId, Theme> = {
  night: { id: 'night', label: 'Night', class: 'theme-night' },
  nightWarm: { id: 'nightWarm', label: 'Night Warm', class: 'theme-night-warm' },
  paper: { id: 'paper', label: 'Paper', class: 'theme-paper' },
};

const ThemeContext = createContext<{
  theme: ThemeId;
  setTheme: (id: ThemeId) => void;
  themes: typeof THEMES;
}>({
  theme: 'night',
  setTheme: () => {},
  themes: THEMES,
});

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setThemeState] = useState<ThemeId>(() => {
    if (typeof window === 'undefined') return 'night';
    const stored = localStorage.getItem('manatsume-theme');
    if (stored === 'nightWarm' || stored === 'paper') return stored as ThemeId;
    return 'night';
  });

  useEffect(() => {
    const root = document.documentElement;
    root.classList.remove('theme-night', 'theme-night-warm', 'theme-paper');
    root.classList.add(THEMES[theme].class);
    try {
      localStorage.setItem('manatsume-theme', theme);
    } catch {
      // ignore
    }
  }, [theme]);

  const setTheme = useCallback((id: ThemeId) => {
    setThemeState(id);
  }, []);

  return React.createElement(
    ThemeContext.Provider,
    { value: { theme, setTheme, themes: THEMES } },
    children,
  );
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return ctx;
}
