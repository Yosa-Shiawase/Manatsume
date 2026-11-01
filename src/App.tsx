import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './hooks/useAuth';
import { ThemeProvider } from './hooks/useTheme';
import { ProtectedRoute } from './lib/router';
import HomePage from './pages/HomePage';
import SearchPage from './pages/SearchPage';
import PlayerPage from './pages/PlayerPage';
import LibraryPage from './pages/LibraryPage';
import AuthPage from './pages/AuthPage';
import LicensesPage from './pages/LicensesPage';
import PrivacyPage from './pages/PrivacyPage';
import SourcesPage from './pages/SourcesPage';
import SettingsPage from './pages/SettingsPage';

export default function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/search" element={<ProtectedRoute><SearchPage /></ProtectedRoute>} />
            <Route path="/player" element={<ProtectedRoute><PlayerPage /></ProtectedRoute>} />
            <Route path="/library" element={<ProtectedRoute><LibraryPage /></ProtectedRoute>} />
            <Route path="/auth" element={<AuthPage />} />
            <Route path="/settings" element={<SettingsPage />} />
            <Route path="/licenses" element={<LicensesPage />} />
            <Route path="/privacy" element={<PrivacyPage />} />
            <Route path="/sources" element={<SourcesPage />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  );
}
