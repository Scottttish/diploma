<template>
  <div>
    <div class="flex items-start justify-between mb-6">
      <div>
        <h1 class="page-title mb-1">{{ $t('dashboard.title') }}</h1>
        <p class="text-sm text-gray-400 dark:text-gray-500">
          {{ today }}
        </p>
      </div>
      <DispatcherAnimation :width="220" :height="140" />
    </div>

    <!-- Stat widgets -->
    <div v-if="loadingOverview" class="flex justify-center py-8">
      <LoadingSpinner />
    </div>
    <div v-else class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3 mb-6">
      <div
        v-for="s in statCards"
        :key="s.status"
        class="card p-4 border-l-4 cursor-default"
        :style="{ borderLeftColor: s.color }"
      >
        <div class="text-2xl font-bold text-gray-900 dark:text-white">{{ s.count }}</div>
        <div class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">{{ s.label }}</div>
      </div>
    </div>

    <!-- Two columns: action queue + worker load -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Очередь заявок -->
      <div class="card overflow-hidden">
        <div class="px-4 py-3 border-b border-gray-100 dark:border-gray-700 flex items-center justify-between">
          <h2 class="font-semibold text-sm text-gray-800 dark:text-gray-200">
            {{ $t('dashboard.actionQueue') }}
          </h2>
          <RouterLink to="/tasks" class="text-xs text-primary dark:text-blue-400 hover:underline">
            Все заявки →
          </RouterLink>
        </div>
        <div v-if="loadingQueue" class="py-6 flex justify-center">
          <LoadingSpinner size="sm" />
        </div>
        <div v-else-if="!urgentTasks.length" class="py-4">
          <EmptyState :message="$t('dashboard.noUrgentTasks')" />
        </div>
        <div v-else class="divide-y divide-gray-100 dark:divide-gray-700">
          <div
            v-for="task in urgentTasks"
            :key="task.id"
            class="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 dark:hover:bg-gray-800/40 cursor-pointer transition-colors"
            @click="router.push('/tasks/' + task.id)"
          >
            <StatusBadge :status="task.status" />
            <span class="flex-1 text-sm font-medium text-gray-800 dark:text-gray-200 truncate">
              {{ task.title }}
            </span>
            <PriorityBadge :priority="task.priority" />
            <span class="text-xs text-gray-400 shrink-0">#{{ task.id }}</span>
          </div>
        </div>
      </div>

      <!-- Нагрузка исполнителей -->
      <div class="card overflow-hidden">
        <div class="px-4 py-3 border-b border-gray-100 dark:border-gray-700 flex items-center justify-between">
          <h2 class="font-semibold text-sm text-gray-800 dark:text-gray-200">
            {{ $t('dashboard.workerLoad') }}
          </h2>
          <RouterLink to="/workers" class="text-xs text-primary dark:text-blue-400 hover:underline">
            Все →
          </RouterLink>
        </div>
        <div v-if="loadingWorkers" class="py-6 flex justify-center">
          <LoadingSpinner size="sm" />
        </div>
        <div v-else-if="!workerStats.length" class="py-4">
          <EmptyState :message="$t('common.noData')" />
        </div>
        <div v-else class="divide-y divide-gray-100 dark:divide-gray-700">
          <div
            v-for="w in workerStats"
            :key="w.worker_id"
            class="flex items-center justify-between px-4 py-3"
          >
            <div class="flex items-center gap-2">
              <div class="w-7 h-7 rounded-full bg-primary/10 dark:bg-primary/20 text-primary text-xs font-semibold flex items-center justify-center">
                {{ getInitials(w.full_name) }}
              </div>
              <span class="text-sm text-gray-700 dark:text-gray-300">{{ w.full_name }}</span>
            </div>
            <div class="flex items-center gap-2">
              <span class="text-xs font-medium text-gray-500 dark:text-gray-400">
                {{ w.completed_tasks }} {{ $t('dashboard.completed') }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import PriorityBadge from '@/components/ui/PriorityBadge.vue'
import DispatcherAnimation from '@/components/animations/DispatcherAnimation.vue'
import { getOverview, getWorkerStats } from '@/api/analytics'
import { getTasks } from '@/api/tasks'
import { getInitials, formatDateShort } from '@/utils/formatters'

const { t } = useI18n()
const router = useRouter()

const overview = ref({ by_status: {}, total: 0, overdue_count: 0 })
const workerStats = ref([])
const urgentTasks = ref([])
const loadingOverview = ref(true)
const loadingWorkers = ref(true)
const loadingQueue = ref(true)

const today = computed(() => {
  return new Date().toLocaleDateString('ru-RU', {
    weekday: 'long', day: 'numeric', month: 'long', year: 'numeric',
  })
})

const STATUS_COLORS = {
  new: '#3B82F6',
  assigned: '#8B5CF6',
  in_progress: '#F59E0B',
  overdue: '#EF4444',
  completed: '#10B981',
  approved: '#10B981',
  rejected: '#6B7280',
}

const statCards = computed(() => {
  const statusOrder = ['new', 'assigned', 'in_progress', 'overdue', 'completed', 'rejected']
  return statusOrder.map((s) => ({
    status: s,
    count: overview.value.by_status?.[s] ?? 0,
    label: t(`status.${s}`),
    color: STATUS_COLORS[s],
  }))
})

onMounted(async () => {
  try {
    const { data } = await getOverview()
    overview.value = data
  } catch {} finally {
    loadingOverview.value = false
  }

  try {
    const { data } = await getWorkerStats()
    workerStats.value = data.slice(0, 8)
  } catch {} finally {
    loadingWorkers.value = false
  }

  try {
    const [overdueRes, newRes] = await Promise.all([
      getTasks({ status: 'overdue', limit: 10 }),
      getTasks({ status: 'new', limit: 10 }),
    ])
    urgentTasks.value = [...overdueRes.data, ...newRes.data].slice(0, 12)
  } catch {} finally {
    loadingQueue.value = false
  }
})
</script>
