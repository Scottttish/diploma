/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{vue,js}'],
  theme: {
    extend: {
      colors: {
        primary: '#1E3A5F',
        'dispatch-bg': '#F5F7FA',
        'dispatch-card': '#FFFFFF',
        'dispatch-dark-card': '#1E1E1E',
        'status-new': '#3B82F6',
        'status-assigned': '#8B5CF6',
        'status-inprogress': '#F59E0B',
        'status-completed': '#10B981',
        'status-overdue': '#EF4444',
        'status-rejected': '#6B7280',
        'status-approved': '#10B981',
      },
      fontFamily: {
        sans: ['Inter', 'IBM Plex Sans', 'Source Sans Pro', 'sans-serif'],
        mono: ['IBM Plex Mono', 'monospace'],
      },
    },
  },
  plugins: [],
}
