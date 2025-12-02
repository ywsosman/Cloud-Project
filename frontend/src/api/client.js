import axios from 'axios';

// Base URL of your backend / API gateway
// Change to 8081 if you call auth-service directly:
// VITE_API_BASE_URL can override this in a .env file.
const baseURL =
  import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080';

const api = axios.create({
  baseURL,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Attach JWT token if present
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;


