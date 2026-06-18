<template>
  <AuthLayout>
    <div class="card w-full max-w-sm p-8">
      <!-- Brand -->
      <div class="flex items-center gap-3 mb-8">
        <div class="w-8 h-8 bg-primary rounded flex items-center justify-center shrink-0">
          <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
          </svg>
        </div>
        <div>
          <h1 class="text-lg font-semibold text-gray-900 dark:text-white leading-tight">Диспетчерская</h1>
          <p class="text-xs text-gray-400">Информационная система</p>
        </div>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleLogin" class="space-y-4">
        <div>
          <label class="label">{{ $t('auth.email') }}</label>
          <input
            v-model="form.email"
            type="email"
            required
            autocomplete="email"
            class="input"
            :placeholder="$t('auth.email')"
          />
        </div>

        <div>
          <label class="label">{{ $t('auth.password') }}</label>
          <input
            v-model="form.password"
            type="password"
            required
            autocomplete="current-password"
            class="input"
            :placeholder="$t('auth.password')"
          />
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="btn-primary w-full mt-6"
        >
          {{ loading ? $t('auth.loggingIn') : $t('auth.login') }}
        </button>

        <p v-if="error" class="text-xs text-status-overdue text-center pt-1">
          {{ error }}
        </p>
      </form>
    </div>
  </AuthLayout>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import AuthLayout from '@/components/layout/AuthLayout.vue'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const form = reactive({ email: '', password: '' })
const loading = ref(false)
const error = ref(null)

async function handleLogin() {
  loading.value = true
  error.value = null
  try {
    await authStore.login(form.email, form.password)
    router.push('/')
  } catch (e) {
    error.value = e.response?.data?.detail || 'Ошибка авторизации. Проверьте данные.'
  } finally {
    loading.value = false
  }
}
</script>
