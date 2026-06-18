import { defineStore } from 'pinia'

export const useUIStore = defineStore('ui', {
  state: () => ({
    darkMode: localStorage.getItem('darkMode') === 'true',
    sidebarCollapsed: false,
    locale: localStorage.getItem('locale') || 'ru',
  }),
  actions: {
    toggleDark() {
      this.darkMode = !this.darkMode
      localStorage.setItem('darkMode', String(this.darkMode))
      document.documentElement.classList.toggle('dark', this.darkMode)
    },
    setLocale(l) {
      this.locale = l
      localStorage.setItem('locale', l)
    },
    toggleSidebar() {
      this.sidebarCollapsed = !this.sidebarCollapsed
    },
  },
})
