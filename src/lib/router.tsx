import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return null;
  }

  if (!user) {
    // Redirect to sign-in, remembering where the user wanted to go.
    const params = new URLSearchParams([['returnTo', location.pathname + location.search]]);
    return <Navigate to={`/auth?${params.toString()}`} replace />;
  }

  return <>{children}</>;
}
