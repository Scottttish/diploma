<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="page-title mb-0">{{ $t('notification.title') }}</h1>
      <button
        v-if="notifications.length"
        class="btn-ghost text-xs"
        @click="handleMarkAllRead"
      >
        {{ $t('notification.markAllRead') }}
      </button>
    </div>

    <div v-if="loading" class="flex justify-center py-12">
      <LoadingSpinner />
    </div>

    <div v-else-if="!notifications.length" class="card">
      <EmptyState :message="$t('notification.noNotifications')" />
    </div>

    <div v-else class="card overflow-hidden divide-y divide-gray-100 dark:divide-gray-700">
      <div
        v-for="n in notifications"
        :key="n.id"
        class="flex gap-3 px-4 py-3.5 transition-colors"
        :class="!n.is_read ? 'bg-blue-50/60 dark:bg-blue-950/10' : ''"
      >
        <!-- Type color dot -->
        <div
          class="w-2.5 h-2.5 rounded-full shrink-0 mt-1.5"
          :class="typeDotClass(n.type)"
        />

        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-800 dark:text-gray-200">{{ n.title }}</p>
          <p class="text-sm text-gray-500 dark:text-gray-400 mt-0.5 leading-snug">{{ n.message }}</p>
          <div class="flex items-center gap-3 mt-1.5">
            <span class="text-xs text-gray-400 dark:text-gray-500">
              {{ formatDate(n.created_at) }}
            </span>
            <span class="text-xs px-1.5 py-0.5 rounded bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400">
              {{ $t(`notification.type.${n.type}`) }}
            </span>
          </div>
        </div>

        <span
          v-if="!n.is_read"
          class="w-2 h-2 rounded-full bg-status-new shrink-0 mt-2"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import { getNotifications, markAllRead } from '@/api/notifications'
import { formatDate } from '@/utils/formatters'

const notifications = ref([])
const loading = ref(true)

const TYPE_DOT = {
  new_task: 'bg-status-new',
  task_assigned: 'bg-status-assigned',
  status_changed: 'bg-status-inprogress',
  task_finished: 'bg-status-completed',
  sla_breached: 'bg-status-overdue',
}

function typeDotClass(type) {
  return TYPE_DOT[type] ?? 'bg-gray-300'
}

async function handleMarkAllRead() {
  try {
    await markAllRead()
    notifications.value = notifications.value.map((n) => ({ ...n, is_read: true }))
  } catch {}
}

onMounted(async () => {
  try {
    const { data } = await getNotifications(false)
    notifications.value = data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})
</script>
