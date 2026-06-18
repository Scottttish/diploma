import { defineStore } from 'pinia'
import { login as apiLogin, getMe } from '@/api/auth'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('auth_token') || null,
    user: null,
  }),
  getters: {
    isAuthenticated: (s) => !!s.token,
    role: (s) => s.user?.role ?? null,

    // Strict single-role checks - the spec forbids cross-role access, so there is no hierarchy here
    isManager:       (s) => s.user?.role === 'manager',
    isAdministrator: (s) => s.user?.role === 'administrator',
    isDispatcher:    (s) => s.user?.role === 'dispatcher',
    isWorker:        (s) => s.user?.role === 'worker',

    // Convenience helper for components that need to check multiple allowed roles at once
    hasRole: (s) => (...roles) => roles.includes(s.user?.role),

    // Each role lands on a different screen after login - workers are blocked entirely
    homeRoute: (s) => ({
      manager:       '/analytics',
      administrator: '/tasks',
      dispatcher:    '/',
      worker:        null,
    }[s.user?.role] ?? '/login'),
  },
  actions: {
    async login(email, password) {
      const { data } = await apiLogin(email, password)
      this.token = data.access_token
      localStorage.setItem('auth_token', data.access_token)
      await this.fetchMe()
    },
    async fetchMe() {
      const { data } = await getMe()
      this.user = data
    },
    logout() {
      this.token = null
      this.user = null
      localStorage.removeItem('auth_token')
    },
  },
})
