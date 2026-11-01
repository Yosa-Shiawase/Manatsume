import React, { createContext, useContext, useState, useCallback, useEffect, type ReactNode } from 'react';
import type { User } from '../types';



const AuthContext = createContext<AuthContextValue | null>(null);

declare const self: {
  CONVEX?: unknown;
  ENV?: { VITE_CONVEX_URL?: string };
};

const storageKey = 'manatsume.localUser';

function localStorageUser(): User | null {
  try {
    const raw = typeof localStorage !== 'undefined'
      ? localStorage.getItem(storageKey)
      : null;
    if (!raw) return null;
    return JSON.parse(raw) as User;
  } catch {
    return null;
  }
}

function persistLocalUser(user: User | null) {
  try {
    if (typeof localStorage === 'undefined') return;
    if (user) {
      localStorage.setItem(storageKey, JSON.stringify(user));
    } else {
      localStorage.removeItem(storageKey);
    }
  } catch {
    // ignore storage errors
  }
}

let realAuth: {
  user: readonly [User | null, () => void];
  signOut: () => Promise<void>;
  loading: boolean;
} | null = null;

function activateConvexAuth() {
  try {
    const ConvexClient = (globalThis as unknown as { ConvexClient?: new (opts?: unknown) => unknown }).ConvexClient;
    const Auth = (globalThis as unknown as { Auth?: new (...args: unknown[]) => unknown }).Auth;

    if (!ConvexClient || !Auth) return;
    if (typeof self === 'undefined' || !self?.CONVEX) return;

    const convexUrl =
      typeof import.meta !== 'undefined'
        ? (import.meta.env?.VITE_CONVEX_URL as string | undefined)
        : undefined;

    const client = new ConvexClient(convexUrl ? { url: convexUrl } : undefined);
    const auth = new Auth(client, {
      // Convex Auth provider configuration goes here when the backend is provisioned.
    }) as unknown as typeof realAuth;
    realAuth = auth;
  } catch {
    // If Convex Auth globals are missing or init fails, continue with the local fallback.
  }
}

activateConvexAuth();

export type AuthContextValue = {
  user: User | null;
  signOut: () => Promise<void>;
  loading: boolean;
  signIn: (email: string, name: string) => User | null;
};

export function AuthProvider({ children }: { children: ReactNode }) {
  const [localUser, setLocalUser] = useState<User | null>(localStorageUser);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (realAuth) {
      // Real auth path is managed by the library when Convex is provisioned.
      setLoading(false);
      return;
    }
    // Local path resolves immediately.
    setLoading(false);
  }, []);

  const user: User | null = realAuth ? realAuth.user[0] : localUser;
  const setUser: (u: User | null) => void = realAuth
    ? realAuth.user[1]
    : setLocalUser;

  const resolveUserByEmail = useCallback(
    (email: string, name: string) => {
      if (!email.trim()) return null;
      const existing = localStorageUser();
      if (existing && existing.email.toLowerCase() === email.trim().toLowerCase()) {
        return existing;
      }
      const id = `local-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 7)}`;
      const local: User = {
        id,
        email: email.trim(),
        name: name.trim() || email.trim().split('@')[0] || 'Listener',
      };
      persistLocalUser(local);
      return local;
    },
    [],
  );

  const signIn = useCallback(
    (email: string, name: string) => {
      const u = resolveUserByEmail(email, name);
      if (u) setUser(u);
      return u;
    },
    [resolveUserByEmail, setUser],
  );

  const signOut: () => Promise<void> = realAuth
    ? realAuth.signOut
    : useCallback(async () => {
        setUser(null);
      }, [setUser]);

  const value: AuthContextValue = {
    user: user ?? null,
    signOut: signOut,
    loading,
    // Exposed so pages can drive real sign-in without reaching into storage directly.
    signIn,
  };

  return React.createElement(
    AuthContext.Provider,
    { value },
    children,
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return ctx;
}


export function resolveDisplayUser(
  user: User | null,
  fallbackEmail = '',
  fallbackName = '',
): User {
  if (user) return user;
  // For local-only demos before real auth is provisioned, synthesize a local user.
  const existing = localStorageUser();
  if (existing) return existing;
  const id = `local-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 7)}`;
  const email = fallbackEmail || `user@localhost`;
  const name = fallbackName || 'Local listener';
  const local: User = { id, email, name };
  persistLocalUser(local);
  return local;
}

/** Restore the currently persisted local user without signing the user in through the provider. */
export function restoreLocalUser(): User | null {
  return localStorageUser();
}
