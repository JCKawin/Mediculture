// Environment configuration for MongoDB API
export const ENV = {
  MONGODB_URI: import.meta.env.VITE_MONGODB_URI || 'mongodb://localhost:27017/pharmacy',
  MONGODB_DB_NAME: import.meta.env.VITE_MONGODB_DB_NAME || 'pharmacy_db',
  API_BASE_URL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api',
} as const;

// MongoDB Collections
export const COLLECTIONS = {
  MEDICATIONS: 'medications',
  ORDERS: 'orders',
  ALERTS: 'alerts',
  INVENTORY: 'inventory',
} as const;

// Type-safe environment validation
export const validateEnv = () => {
  const required = ['VITE_MONGODB_URI'];
  const missing = required.filter(key => !import.meta.env[key]);
  
  if (missing.length > 0) {
    console.warn(`Missing environment variables: ${missing.join(', ')}`);
    console.warn('Using default development values. Please set up your .env file for production.');
  }
};