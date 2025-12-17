import React, { useState, useEffect } from 'react';
import api from '../api/client.js';

export default function MFASettings() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [mfaSetup, setMfaSetup] = useState(null);
  const [verificationCode, setVerificationCode] = useState('');
  const [showVerification, setShowVerification] = useState(false);

  // Load user info
  useEffect(() => {
    loadUserInfo();
  }, []);

  const loadUserInfo = async () => {
    try {
      const res = await api.get('/api/auth/me');
      setUser(res.data.user);
    } catch (err) {
      setError('Failed to load user information');
    }
  };

  const handleEnableMFA = async () => {
    setError('');
    setSuccess('');
    setLoading(true);

    try {
      const res = await api.post('/api/auth/mfa/enable');
      setMfaSetup(res.data);
      setShowVerification(true);
      setSuccess('QR code generated. Scan it with your authenticator app.');
    } catch (err) {
      const msg =
        err.response?.data?.error || 'Failed to enable MFA. Please try again.';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyMFA = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);

    try {
      await api.post('/api/auth/mfa/verify', {
        token: verificationCode
      });

      setSuccess('MFA enabled successfully!');
      setShowVerification(false);
      setMfaSetup(null);
      setVerificationCode('');
      await loadUserInfo(); // Refresh user info
    } catch (err) {
      const msg =
        err.response?.data?.error ||
        'Invalid verification code. Please try again.';
      setError(msg);
      setVerificationCode('');
    } finally {
      setLoading(false);
    }
  };

  const handleDisableMFA = async () => {
    if (
      !window.confirm(
        'Are you sure you want to disable MFA? This will reduce your account security.'
      )
    ) {
      return;
    }

    setError('');
    setSuccess('');
    setLoading(true);

    try {
      // Note: You may need to add a disable endpoint
      // For now, this is a placeholder
      setError('MFA disable feature coming soon. Contact administrator.');
      // await api.post('/api/auth/mfa/disable');
      // setSuccess('MFA disabled successfully');
      // await loadUserInfo();
    } catch (err) {
      const msg =
        err.response?.data?.error || 'Failed to disable MFA. Please try again.';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  if (!user) {
    return (
      <div className="page">
        <div className="card">
          <p>Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="page">
      <div className="page-header">
        <h2>Multi-Factor Authentication (MFA)</h2>
        <p className="subtitle">
          Add an extra layer of security to your account
        </p>
      </div>

      <div className="card">
        {error && <div className="alert alert-error">{error}</div>}
        {success && <div className="alert alert-success">{success}</div>}

        <div className="mfa-status">
          <h3>Current Status</h3>
          <div className="status-badge">
            {user.mfaEnabled ? (
              <span className="badge badge-success">MFA Enabled</span>
            ) : (
              <span className="badge badge-warning">MFA Disabled</span>
            )}
          </div>
        </div>

        {!user.mfaEnabled && !showVerification && (
          <div className="mfa-setup">
            <h3>Enable MFA</h3>
            <p>
              Multi-factor authentication adds an extra layer of security by
              requiring a code from your authenticator app in addition to your
              password.
            </p>
            <button
              className="btn btn-primary"
              onClick={handleEnableMFA}
              disabled={loading}
            >
              {loading ? 'Generating...' : 'Enable MFA'}
            </button>
          </div>
        )}

        {showVerification && mfaSetup && (
          <div className="mfa-verification">
            <h3>Scan QR Code</h3>
            <p>
              1. Open your authenticator app (Google Authenticator, Microsoft
              Authenticator, etc.)
            </p>
            <p>2. Scan this QR code:</p>

            <div className="qr-code-container">
              <img
                src={mfaSetup.qrCode}
                alt="MFA QR Code"
                className="qr-code"
              />
            </div>

            <p>
              <strong>Or enter this secret manually:</strong>
            </p>
            <div className="secret-key">
              <code>{mfaSetup.secret}</code>
              <button
                className="btn btn-small"
                onClick={() => {
                  navigator.clipboard.writeText(mfaSetup.secret);
                  setSuccess('Secret copied to clipboard!');
                }}
              >
                Copy
              </button>
            </div>

            <p>3. Enter the 6-digit code from your app to verify:</p>

            <form onSubmit={handleVerifyMFA} className="form">
              <label>
                Verification Code
                <input
                  type="text"
                  value={verificationCode}
                  onChange={(e) =>
                    setVerificationCode(
                      e.target.value.replace(/\D/g, '').slice(0, 6)
                    )
                  }
                  placeholder="000000"
                  maxLength="6"
                  required
                  autoFocus
                  style={{
                    textAlign: 'center',
                    letterSpacing: '0.5em',
                    fontSize: '1.2em',
                    fontFamily: 'monospace'
                  }}
                />
              </label>

              <div className="form-actions">
                <button
                  className="btn btn-primary"
                  type="submit"
                  disabled={loading || verificationCode.length !== 6}
                >
                  {loading ? 'Verifying...' : 'Verify & Enable'}
                </button>
                <button
                  type="button"
                  className="btn btn-outline"
                  onClick={() => {
                    setShowVerification(false);
                    setMfaSetup(null);
                    setVerificationCode('');
                    setError('');
                    setSuccess('');
                  }}
                  disabled={loading}
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        )}

        {user.mfaEnabled && (
          <div className="mfa-enabled">
            <h3>MFA is Active</h3>
            <p>
              Your account is protected with multi-factor authentication. You
              will be asked for a code from your authenticator app each time you
              log in.
            </p>
            <button
              className="btn btn-outline btn-danger"
              onClick={handleDisableMFA}
              disabled={loading}
            >
              {loading ? 'Disabling...' : 'Disable MFA'}
            </button>
          </div>
        )}
      </div>

      <div className="card">
        <h3>About MFA</h3>
        <ul className="info-list">
          <li>
            <strong>What is MFA?</strong> Multi-factor authentication requires
            two forms of verification: your password and a code from your phone.
          </li>
          <li>
            <strong>Why use it?</strong> Even if someone steals your password,
            they can't access your account without your phone.
          </li>
          <li>
            <strong>Which apps work?</strong> Google Authenticator, Microsoft
            Authenticator, Authy, and any TOTP-compatible app.
          </li>
          <li>
            <strong>Lost your phone?</strong> Contact an administrator to reset
            MFA.
          </li>
        </ul>
      </div>
    </div>
  );
}

