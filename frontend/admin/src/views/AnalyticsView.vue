<template>
  <div>
    <h1 class="page-title">{{ $t('analytics.title') }}</h1>

    <div v-if="loading" class="flex justify-center py-12">
      <LoadingSpinner />
    </div>

    <template v-else>
      <!-- Status overview grid -->
      <div class="mb-2">
        <h2 class="text-sm font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-3">
          {{ $t('analytics.overview') }}
        </h2>
        <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-7 gap-3 mb-6">
          <div
            v-for="(count, status) in overview.by_status"
            :key="status"
            class="card p-4 border-l-4"
            :style="{ borderLeftColor: STATUS_COLORS[status] ?? '#9CA3AF' }"
          >
            <div class="text-2xl font-bold text-gray-900 dark:text-white">{{ count }}</div>
            <div class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">{{ $t(`status.${status}`) }}</div>
          </div>
          <div class="card p-4 border-l-4 border-l-status-overdue">
            <div class="text-2xl font-bold text-status-overdue">{{ overview.overdue_count ?? 0 }}</div>
            <div class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">Просрочено (всего)</div>
          </div>
        </div>
      </div>

      <!-- Worker performance table -->
      <div class="card overflow-hidden mb-6">
        <div class="px-4 py-3 border-b border-gray-100 dark:border-gray-700">
          <h2 class="font-semibold text-sm text-gray-800 dark:text-gray-200">
            {{ $t('analytics.workerPerformance') }}
          </h2>
        </div>
        <table class="w-full">
          <thead class="table-header">
            <tr>
              <th class="table-cell">{{ $t('workers.name') }}</th>
              <th class="table-cell text-right">{{ $t('analytics.completed') }}</th>
              <th class="table-cell text-right">{{ $t('analytics.avgTime') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="w in workerStats" :key="w.worker_id" class="border-b border-gray-100 dark:border-gray-700/50">
              <td class="table-cell">
                <div class="flex items-center gap-2">
                  <div class="w-7 h-7 rounded-full bg-primary/10 dark:bg-primary/20 text-primary text-xs font-semibold flex items-center justify-center shrink-0">
                    {{ getInitials(w.full_name) }}
                  </div>
                  {{ w.full_name }}
                </div>
              </td>
              <td class="table-cell text-right font-semibold text-gray-800 dark:text-gray-200">
                {{ w.completed_tasks }}
              </td>
              <td class="table-cell text-right text-gray-500 dark:text-gray-400">
                {{ avgHours(w.avg_completion_seconds) }}
              </td>
            </tr>
          </tbody>
        </table>
        <EmptyState v-if="!workerStats.length" />
      </div>

      <!-- Service types table -->
      <div class="card overflow-hidden">
        <div class="px-4 py-3 border-b border-gray-100 dark:border-gray-700">
          <h2 class="font-semibold text-sm text-gray-800 dark:text-gray-200">
            {{ $t('analytics.serviceTypes') }}
          </h2>
        </div>
        <table class="w-full">
          <thead class="table-header">
            <tr>
              <th class="table-cell">Тип услуги</th>
              <th class="table-cell text-right">{{ $t('analytics.totalTasks') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="st in serviceTypeStats" :key="st.service_type_id" class="border-b border-gray-100 dark:border-gray-700/50">
              <td class="table-cell text-gray-700 dark:text-gray-300">{{ st.name ?? `#${st.service_type_id}` }}</td>
              <td class="table-cell text-right font-semibold text-gray-800 dark:text-gray-200">{{ st.total_tasks }}</td>
            </tr>
          </tbody>
        </table>
        <EmptyState v-if="!serviceTypeStats.length" />
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import { getOverview, getWorkerStats, getServiceTypeStats } from '@/api/analytics'
import { getInitials } from '@/utils/formatters'

const loading = ref(true)
const overview = ref({ by_status: {}, total: 0, overdue_count: 0 })
const workerStats = ref([])
const serviceTypeStats = ref([])

const STATUS_COLORS = {
  new: '#3B82F6', assigned: '#8B5CF6', in_progress: '#F59E0B',
  completed: '#10B981', approved: '#10B981', rejected: '#6B7280', overdue: '#EF4444',
}

function avgHours(seconds) {
  if (!seconds) return '-'
  const h = seconds / 3600
  return h < 1 ? `${Math.round(seconds / 60)} мин` : `${h.toFixed(1)} ч`
}

onMounted(async () => {
  try {
    const [overviewRes, workersRes, stRes] = await Promise.all([
      getOverview(),
      getWorkerStats(),
      getServiceTypeStats(),
    ])
    overview.value = overviewRes.data
    workerStats.value = workersRes.data
    serviceTypeStats.value = stRes.data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})
</script>
