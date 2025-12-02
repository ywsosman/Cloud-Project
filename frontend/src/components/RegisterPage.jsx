import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../api/client.js';

export default function RegisterPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    username: '',
    email: '',
    password: '',
    firstName: '',
    lastName: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);

    try {
      await api.post('/api/auth/register', form);
      setSuccess('Registration successful. You can now log in.');
      setTimeout(() => navigate('/login'), 800);
    } catch (err) {
      const msg =
        err.response?.data?.errors?.[0]?.msg ||
        err.response?.data?.error ||
        'Registration failed.';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="card auth-card">
        <h2>Register</h2>
        <p className="subtitle">Create an account for the lab environment.</p>

        {error && <div className="alert alert-error">{error}</div>}
        {success && <div className="alert alert-success">{success}</div>}

        <div className="password-hint">
          Password must be at least 8 characters and include uppercase,
          lowercase, a number, and a special character.
        </div>

        <form onSubmit={handleSubmit} className="form">
          <label>
            Username
            <input
              name="username"
              value={form.username}
              onChange={handleChange}
              required
            />
          </label>

          <label>
            Email
            <input
              type="email"
              name="email"
              value={form.email}
              onChange={handleChange}
              required
            />
          </label>

          <label>
            Password
            <input
              type="password"
              name="password"
              value={form.password}
              onChange={handleChange}
              required
            />
          </label>

          <div className="grid-2">
            <label>
              First name
              <input
                name="firstName"
                value={form.firstName}
                onChange={handleChange}
              />
            </label>
            <label>
              Last name
              <input
                name="lastName"
                value={form.lastName}
                onChange={handleChange}
              />
            </label>
          </div>

          <button className="btn btn-primary" type="submit" disabled={loading}>
            {loading ? 'Registering...' : 'Register'}
          </button>
        </form>

        <p className="switch-text">
          Already have an account? <Link to="/login">Login</Link>
        </p>
      </div>
    </div>
  );
}


