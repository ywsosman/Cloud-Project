import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import NavBar from './components/NavBar.jsx';
import LoginPage from './components/LoginPage.jsx';
import RegisterPage from './components/RegisterPage.jsx';
import SecurityDashboard from './components/SecurityDashboard.jsx';
import MFASettings from './components/MFASettings.jsx';

function isAuthenticated() {
  const token = localStorage.getItem('accessToken');
  return Boolean(token);
}

function PrivateRoute({ children }) {
  return isAuthenticated() ? children : <Navigate to="/login" replace />;
}

export default function App() {
  return (
    <div className="app-root">
      <NavBar />
      <main className="app-main">
        <Routes>
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route
            path="/dashboard"
            element={
              <PrivateRoute>
                <SecurityDashboard />
              </PrivateRoute>
            }
          />
          <Route
            path="/settings/mfa"
            element={
              <PrivateRoute>
                <MFASettings />
              </PrivateRoute>
            }
          />
          <Route path="*" element={<div className="card">Page not found</div>} />
        </Routes>
      </main>
    </div>
  );
}


