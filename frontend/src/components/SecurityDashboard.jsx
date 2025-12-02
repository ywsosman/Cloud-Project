import React, { useEffect, useState } from 'react';
import api from '../api/client.js';

export default function SecurityDashboard() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [filters, setFilters] = useState({
    status: '',
    caller: '',
    limit: 25
  });

  const loadLogs = async () => {
    setLoading(true);
    setError('');
    try {
      const params = {};
      if (filters.status) params.status = filters.status;
      if (filters.caller) params.caller = filters.caller;
      if (filters.limit) params.limit = filters.limit;

      const res = await api.get('/api/security/activity-logs', { params });
      setLogs(res.data.data || []);
    } catch (err) {
      const msg =
        err.response?.data?.error ||
        'Failed to load activity logs. Check that the backend is running.';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadLogs();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFilters((prev) => ({ ...prev, [name]: value }));
  };

  const handleApplyFilters = (e) => {
    e.preventDefault();
    loadLogs();
  };

  return (
    <div className="page">
      <div className="page-header">
        <h2>Security Activity Dashboard</h2>
        <p className="subtitle">
          Viewing Azure Activity Logs from your subscription (Zero-Trust lab
          dataset).
        </p>
      </div>

      <div className="card">
        <form className="filters" onSubmit={handleApplyFilters}>
          <div>
            <label>
              Status
              <select
                name="status"
                value={filters.status}
                onChange={handleChange}
              >
                <option value="">Any</option>
                <option value="Succeeded">Succeeded</option>
                <option value="Started">Started</option>
                <option value="Failed">Failed</option>
              </select>
            </label>
          </div>
          <div>
            <label>
              Caller contains
              <input
                name="caller"
                value={filters.caller}
                onChange={handleChange}
                placeholder="email or UPN"
              />
            </label>
          </div>
          <div>
            <label>
              Limit
              <input
                type="number"
                name="limit"
                min="1"
                max="200"
                value={filters.limit}
                onChange={handleChange}
              />
            </label>
          </div>
          <button className="btn btn-primary" type="submit" disabled={loading}>
            {loading ? 'Loading...' : 'Apply'}
          </button>
        </form>

        {error && <div className="alert alert-error">{error}</div>}

        <div className="table-wrapper">
          <table className="table">
            <thead>
              <tr>
                <th>Timestamp</th>
                <th>Operation</th>
                <th>Status</th>
                <th>Caller</th>
                <th>Resource Group</th>
              </tr>
            </thead>
            <tbody>
              {logs.length === 0 && !loading && (
                <tr>
                  <td colSpan="5" style={{ textAlign: 'center' }}>
                    No activity logs found for these filters.
                  </td>
                </tr>
              )}
              {logs.map((log, idx) => (
                <tr key={idx}>
                  <td>{log.timestamp}</td>
                  <td>{log.operation}</td>
                  <td>{log.status}</td>
                  <td>{log.caller}</td>
                  <td>{log.resource_group}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}


