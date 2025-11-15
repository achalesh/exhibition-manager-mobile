// frontend/vite.config.mjs
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [ react() ],
  server: {
    host: true  // ensures Vite listens on 0.0.0.0 inside container
  }
});
