import react from "@vitejs/plugin-react";
import tailwind from "tailwindcss";
import { defineConfig } from "vite";
import { resolve } from "path";

export default defineConfig({
  plugins: [react()],
  css: {
    postcss: {
      plugins: [tailwind()],
    },
  },
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'src/index.tsx')
      }
    }
  }
});