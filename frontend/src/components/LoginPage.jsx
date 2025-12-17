import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../api/client.js';

export default function LoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [mfaToken, setMfaToken] = useState('');
  const [mfaCode, setMfaCode] = useState('');
  const [showMfa, setShowMfa] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await api.post('/api/auth/login', { email, password });

      if (res.data.requiresMfa) {
        // MFA required - show MFA input
        setMfaToken(res.data.mfaToken);
        setShowMfa(true);
      } else {
        localStorage.setItem('accessToken', res.data.accessToken);
        if (res.data.refreshToken) {
          localStorage.setItem('refreshToken', res.data.refreshToken);
        }
        navigate('/dashboard');
      }
    } catch (err) {
      const msg =
        err.response?.data?.error || 'Login failed. Please check credentials.';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  const handleMfaSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await api.post('/api/auth/verify-mfa', {
        mfaToken,
        token: mfaCode
      });

      localStorage.setItem('accessToken', res.data.accessToken);
      if (res.data.refreshToken) {
        localStorage.setItem('refreshToken', res.data.refreshToken);
      }
      navigate('/dashboard');
    } catch (err) {
      const msg =
        err.response?.data?.error || 'Invalid MFA code. Please try again.';
      setError(msg);
      setMfaCode('');
    } finally {
      setLoading(false);
    }
  };

  if (showMfa) {
    return (
      <div className="auth-container">
        <div className="card auth-card">
          <h2>Multi-Factor Authentication</h2>
          <p className="subtitle">
            Enter the 6-digit code from your authenticator app.
          </p>

          {error && <div className="alert alert-error">{error}</div>}

          <form onSubmit={handleMfaSubmit} className="form">
            <label>
              MFA Code
              <input
                type="text"
                value={mfaCode}
                onChange={(e) => setMfaCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
                placeholder="000000"
                maxLength="6"
                required
                autoFocus
                style={{ textAlign: 'center', letterSpacing: '0.5em', fontSize: '1.2em' }}
              />
            </label>

            <button className="btn btn-primary" type="submit" disabled={loading || mfaCode.length !== 6}>
              {loading ? 'Verifying...' : 'Verify'}
            </button>

            <button
              type="button"
              className="btn btn-outline"
              onClick={() => {
                setShowMfa(false);
                setMfaToken('');
                setMfaCode('');
                setError('');
              }}
              disabled={loading}
            >
              Back to Login
            </button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="auth-container">
      <div className="card auth-card">
        <h2>Login</h2>
        <p className="subtitle">
          Sign in to access the Zero-Trust security dashboard.
        </p>

        {error && <div className="alert alert-error">{error}</div>}

        <form onSubmit={handleSubmit} className="form">
          <label>
            Email
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </label>

          <label>
            Password
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </label>

          <button className="btn btn-primary" type="submit" disabled={loading}>
            {loading ? 'Logging in...' : 'Login'}
          </button>
        </form>

        <p className="switch-text">
          Don&apos;t have an account? <Link to="/register">Register</Link>
        </p>
      </div>
    </div>
  );
}


