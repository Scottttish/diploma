import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
  {
    path: '/login',
    component: () => import('@/views/LoginView.vue'),
    meta: { public: true },
  },
  {
    path: '/',
    component: () => import('@/components/layout/AppLayout.vue'),
    children: [
      {
        path: '',
        component: () => import('@/views/DashboardView.vue'),
        meta: { requiresRoles: ['dispatcher'] },
      },
      {
        path: 'tasks',
        component: () => import('@/views/TasksView.vue'),
        meta: { requiresRoles: ['dispatcher', 'administrator'] },
      },
      {
        path: 'tasks/:id',
        component: () => import('@/views/TaskDetailView.vue'),
        meta: { requiresRoles: ['dispatcher', 'administrator'] },
      },
      {
        path: 'workers',
        component: () => import('@/views/WorkersView.vue'),
        meta: { requiresRoles: ['manager'] },
      },
      {
        path: 'chats',
        component: () => import('@/views/ChatsView.vue'),
        meta: { requiresRoles: ['dispatcher', 'manager', 'administrator'] },
      },
      {
        path: 'scheduling',
        component: () => import('@/views/SchedulingView.vue'),
        meta: { requiresRoles: ['dispatcher'] },
      },
      {
        path: 'map',
        component: () => import('@/views/MapView.vue'),
        meta: { requiresRoles: ['dispatcher'] },
      },
      {
        path: 'analytics',
        component: () => import('@/views/AnalyticsView.vue'),
        meta: { requiresRoles: ['manager'] },
      },
      {
        path: 'directories',
        component: () => import('@/views/DirectoriesView.vue'),
        meta: { requiresRoles: ['administrator'] },
      },
      {
        path: 'clients',
        component: () => import('@/views/ClientsView.vue'),
        meta: { requiresRoles: ['manager'] },
      },
      {
        path: 'notifications',
        component: () => import('@/views/NotificationsView.vue'),
        meta: { requiresRoles: ['manager', 'administrator', 'dispatcher'] },
      },
      {
        path: 'settings',
        component: () => import('@/views/SettingsView.vue'),
        meta: { requiresRoles: ['manager', 'administrator', 'dispatcher'] },
      },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach(async (to) => {
  if (to.meta.public) return true

  const auth = useAuthStore()
  if (!auth.isAuthenticated) return { path: '/login' }

  if (!auth.user) {
    try {
      await auth.fetchMe()
    } catch {
      return { path: '/login' }
    }
  }

  // Workers have no access to the admin panel - redirect them back to login immediately
  if (auth.isWorker) return { path: '/login' }

  // Enforce per-route role requirements; unauthorized users land on their own home screen
  const allowed = to.meta.requiresRoles
  if (allowed && !allowed.includes(auth.role)) {
    return { path: auth.homeRoute }
  }

  return true
})

export default router
