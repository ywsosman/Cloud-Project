import React from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';

export default function NavBar() {
  const navigate = useNavigate();
  const location = useLocation();
  const token = localStorage.getItem('accessToken');

  const handleLogout = () => {
    localStorage.removeItem('accessToken');
    navigate('/login');
  };

  return (
    <header className="navbar">
      <div className="navbar-left">
        <span className="navbar-brand">Zero-Trust Cloud Lab</span>
      </div>
      <nav className="navbar-links">
        {token && (
          <>
            <Link
              to="/dashboard"
              className={location.pathname === '/dashboard' ? 'active' : ''}
            >
              Security Dashboard
            </Link>
            <Link
              to="/settings/mfa"
              className={location.pathname === '/settings/mfa' ? 'active' : ''}
            >
              MFA Settings
            </Link>
          </>
        )}
        {!token && (
          <>
            <Link
              to="/login"
              className={location.pathname === '/login' ? 'active' : ''}
            >
              Login
            </Link>
            <Link
              to="/register"
              className={location.pathname === '/register' ? 'active' : ''}
            >
              Register
            </Link>
          </>
        )}
      </nav>
      <div className="navbar-right">
        {token && (
          <button className="btn btn-outline" onClick={handleLogout}>
            Logout
          </button>
        )}
      </div>
    </header>
  );
}


