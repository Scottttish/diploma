<template>
  <div>
    <h1 class="page-title">{{ $t('settings.title') }}</h1>

    <div class="max-w-lg space-y-6">
      <!-- Profile -->
      <div class="card p-6">
        <h2 class="font-semibold text-gray-800 dark:text-gray-200 mb-4">{{ $t('settings.profile') }}</h2>
        <div class="flex items-center gap-4 mb-4">
          <div class="w-14 h-14 rounded-full bg-primary text-white text-xl font-semibold flex items-center justify-center shrink-0">
            {{ initials }}
          </div>
          <div>
            <p class="font-semibold text-gray-900 dark:text-white">{{ authStore.user?.full_name }}</p>
            <p class="text-sm text-gray-500 dark:text-gray-400">{{ authStore.user?.email }}</p>
          </div>
        </div>
        <div class="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p class="label">{{ $t('settings.currentRole') }}</p>
            <p class="text-gray-700 dark:text-gray-300">
              {{ authStore.user?.role ? $t(`role.${authStore.user.role}`) : '-' }}
            </p>
          </div>
          <div>
            <p class="label">ID</p>
            <p class="text-gray-700 dark:text-gray-300 font-mono">{{ authStore.user?.id }}</p>
          </div>
        </div>
      </div>

      <!-- Language -->
      <div class="card p-6">
        <h2 class="font-semibold text-gray-800 dark:text-gray-200 mb-4">{{ $t('settings.language') }}</h2>
        <div class="flex gap-2">
          <button
            v-for="lang in languages"
            :key="lang.code"
            class="px-5 py-2 rounded border text-sm font-semibold transition-colors"
            :class="uiStore.locale === lang.code
              ? 'bg-primary text-white border-primary'
              : 'border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:border-primary hover:text-primary'"
            @click="setLocale(lang.code)"
          >
            {{ lang.label }}
          </button>
        </div>
      </div>

      <!-- Theme -->
      <div class="card p-6">
        <h2 class="font-semibold text-gray-800 dark:text-gray-200 mb-4">{{ $t('settings.theme') }}</h2>
        <div class="flex gap-2">
          <button
            class="flex items-center gap-2 px-4 py-2 rounded border text-sm font-medium transition-colors"
            :class="!uiStore.darkMode
              ? 'bg-primary text-white border-primary'
              : 'border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:border-primary'"
            @click="setTheme(false)"
          >
            <SunIcon class="w-4 h-4" />
            {{ $t('settings.light') }}
          </button>
          <button
            class="flex items-center gap-2 px-4 py-2 rounded border text-sm font-medium transition-colors"
            :class="uiStore.darkMode
              ? 'bg-primary text-white border-primary'
              : 'border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:border-primary'"
            @click="setTheme(true)"
          >
            <MoonIcon class="w-4 h-4" />
            {{ $t('settings.dark') }}
          </button>
        </div>
      </div>

      <!-- Change Password -->
      <div class="card p-6">
        <h2 class="font-semibold text-gray-800 dark:text-gray-200 mb-4">Смена пароля</h2>
        <div class="space-y-3">
          <div>
            <label class="label">Текущий пароль</label>
            <input v-model="pwForm.current" type="password" class="input" autocomplete="current-password" />
          </div>
          <div>
            <label class="label">Новый пароль</label>
            <input v-model="pwForm.next" type="password" class="input" autocomplete="new-password" />
          </div>
          <button class="btn-primary" :disabled="pwSaving" @click="submitPasswordChange">
            {{ pwSaving ? 'Сохранение...' : 'Сохранить' }}
          </button>
          <p v-if="pwMsg" class="text-xs" :class="pwError ? 'text-status-overdue' : 'text-status-completed'">
            {{ pwMsg }}
          </p>
        </div>
      </div>

      <!-- Danger -->
      <div class="card p-6">
        <h2 class="font-semibold text-gray-800 dark:text-gray-200 mb-4">Сессия</h2>
        <button class="btn-ghost text-status-overdue border-status-overdue/30 hover:bg-status-overdue/5" @click="handleLogout">
          {{ $t('auth.logout') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { SunIcon, MoonIcon } from '@heroicons/vue/24/outline'
import { useAuthStore } from '@/stores/auth'
import { useUIStore } from '@/stores/ui'
import { getInitials } from '@/utils/formatters'
import { changeMyPassword } from '@/api/users'

const { locale } = useI18n()
const router = useRouter()
const authStore = useAuthStore()
const uiStore = useUIStore()

const initials = computed(() => getInitials(authStore.user?.full_name))

const pwForm   = ref({ current: '', next: '' })
const pwSaving = ref(false)
const pwMsg    = ref('')
const pwError  = ref(false)

async function submitPasswordChange() {
  if (!pwForm.value.current || !pwForm.value.next) return
  pwSaving.value = true
  pwMsg.value    = ''
  try {
    await changeMyPassword(pwForm.value.current, pwForm.value.next)
    pwMsg.value   = 'Пароль успешно изменён'
    pwError.value = false
    pwForm.value  = { current: '', next: '' }
  } catch (e) {
    pwMsg.value   = e.response?.data?.detail ?? 'Ошибка смены пароля'
    pwError.value = true
  } finally {
    pwSaving.value = false
  }
}

const languages = [
  { code: 'ru', label: 'РУ' },
  { code: 'en', label: 'EN' },
  { code: 'kk', label: 'ҚЗ' },
]

function setLocale(code) {
  uiStore.setLocale(code)
  locale.value = code
}

function setTheme(dark) {
  if (uiStore.darkMode !== dark) uiStore.toggleDark()
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}
</script>
