<template>
  <header class="h-14 px-6 flex items-center justify-between bg-white dark:bg-dispatch-dark-card border-b border-gray-200 dark:border-gray-700 shrink-0">
    <!-- Breadcrumb -->
    <nav class="flex items-center gap-1.5 text-sm">
      <span class="text-gray-400 dark:text-gray-500">
        {{ appName }}
      </span>
      <template v-if="breadcrumbs.length">
        <span class="text-gray-300 dark:text-gray-600">/</span>
        <span
          v-for="(crumb, i) in breadcrumbs"
          :key="i"
          class="flex items-center gap-1.5"
        >
          <span
            :class="i === breadcrumbs.length - 1
              ? 'font-medium text-gray-800 dark:text-gray-200'
              : 'text-gray-400 dark:text-gray-500'"
          >{{ crumb }}</span>
          <span v-if="i < breadcrumbs.length - 1" class="text-gray-300 dark:text-gray-600">/</span>
        </span>
      </template>
    </nav>

    <!-- Right actions -->
    <div class="flex items-center gap-3">
      <!-- Dark mode toggle -->
      <button
        class="w-8 h-8 flex items-center justify-center rounded hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-500 dark:text-gray-400 transition-colors"
        :title="uiStore.darkMode ? 'Светлая тема' : 'Тёмная тема'"
        @click="uiStore.toggleDark()"
      >
        <SunIcon v-if="uiStore.darkMode" class="w-5 h-5" />
        <MoonIcon v-else class="w-5 h-5" />
      </button>

      <!-- Notifications bell -->
      <RouterLink
        to="/notifications"
        class="relative w-8 h-8 flex items-center justify-center rounded hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-500 dark:text-gray-400 transition-colors"
      >
        <BellIcon class="w-5 h-5" />
        <span
          v-if="hasUnread"
          class="absolute top-1 right-1 w-2 h-2 rounded-full bg-status-overdue"
        />
      </RouterLink>

      <!-- User avatar + dropdown -->
      <div class="relative" ref="avatarRef">
        <button
          class="flex items-center gap-2 rounded px-2 py-1 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          @click="showDropdown = !showDropdown"
        >
          <div
            class="w-7 h-7 rounded-full bg-primary text-white text-xs font-semibold flex items-center justify-center"
          >
            {{ initials }}
          </div>
          <span class="text-sm text-gray-700 dark:text-gray-300 hidden sm:block max-w-28 truncate">
            {{ authStore.user?.full_name }}
          </span>
          <ChevronDownIcon class="w-3.5 h-3.5 text-gray-400" />
        </button>

        <!-- Dropdown -->
        <div
          v-if="showDropdown"
          class="absolute right-0 top-full mt-1 w-44 bg-white dark:bg-dispatch-dark-card border border-gray-200 dark:border-gray-700 rounded shadow-lg z-50"
        >
          <div class="px-3 py-2 border-b border-gray-100 dark:border-gray-700">
            <p class="text-xs font-medium text-gray-800 dark:text-gray-200 truncate">
              {{ authStore.user?.full_name }}
            </p>
            <p class="text-xs text-gray-400 truncate">{{ authStore.user?.email }}</p>
          </div>
          <button
            class="w-full flex items-center gap-2 px-3 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
            @click="handleLogout"
          >
            <ArrowRightOnRectangleIcon class="w-4 h-4" />
            {{ $t('auth.logout') }}
          </button>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '@/stores/auth'
import { useUIStore } from '@/stores/ui'
import { getInitials } from '@/utils/formatters'
import { getNotifications } from '@/api/notifications'
import {
  BellIcon,
  SunIcon,
  MoonIcon,
  ChevronDownIcon,
  ArrowRightOnRectangleIcon,
} from '@heroicons/vue/24/outline'

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const uiStore = useUIStore()

const appName = 'ASAR'
const showDropdown = ref(false)
const avatarRef = ref(null)
const hasUnread = ref(false)

const initials = computed(() => getInitials(authStore.user?.full_name))

const ROUTE_LABELS = {
  '/': () => t('nav.dashboard'),
  '/tasks': () => t('nav.tasks'),
  '/workers': () => t('nav.workers'),
  '/scheduling': () => t('nav.scheduling'),
  '/map': () => t('nav.map'),
  '/analytics': () => t('nav.analytics'),
  '/notifications': () => t('nav.notifications'),
  '/settings': () => t('nav.settings'),
}

const breadcrumbs = computed(() => {
  const path = route.path
  if (path === '/') return []
  const parts = []
  const base = '/' + path.split('/')[1]
  if (ROUTE_LABELS[base]) parts.push(ROUTE_LABELS[base]())
  if (route.params.id) parts.push(`#${route.params.id}`)
  return parts
})

async function fetchUnreadCount() {
  try {
    const { data } = await getNotifications(true)
    hasUnread.value = data.length > 0
  } catch {}
}

function handleClickOutside(e) {
  if (avatarRef.value && !avatarRef.value.contains(e.target)) {
    showDropdown.value = false
  }
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  fetchUnreadCount()
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>
