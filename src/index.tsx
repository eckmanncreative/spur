import React from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AppHome } from './screens/AppHome';
import { Login } from './screens/Login';
import { CompleteSignup } from './screens/CompleteSignup';
import { getCurrentUser } from './lib/supabase';

const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const [isAuthenticated, setIsAuthenticated] = React.useState<boolean | null>(null);

  React.useEffect(() => {
    getCurrentUser().then(user => {
      setIsAuthenticated(!!user);
    });
  }, []);

  if (isAuthenticated === null) {
    return null; // Loading state
  }

  return isAuthenticated ? <>{children}</> : <Navigate to="/login" />;
};

createRoot(document.getElementById('app') as HTMLElement).render(
  <React.StrictMode>
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="/login" element={<Login />} />
        <Route
          path="/complete-signup"
          element={
            <ProtectedRoute>
              <CompleteSignup />
            </ProtectedRoute>
          }
        />
        <Route
          path="/home"
          element={
            <ProtectedRoute>
              <AppHome />
            </ProtectedRoute>
          }
        />
      </Routes>
    </Router>
  </React.StrictMode>
);