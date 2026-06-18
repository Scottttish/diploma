<template>
  <div class="flex gap-0 h-full -m-6">
    <!-- Filter sidebar -->
    <aside class="w-48 shrink-0 bg-white dark:bg-dispatch-dark-card border-r border-gray-200 dark:border-gray-700 p-4 h-full overflow-y-auto">
      <h3 class="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-3">
        {{ $t('common.filter') }}
      </h3>

      <!-- All -->
      <label class="flex items-center gap-2 py-1.5 cursor-pointer">
        <input
          type="checkbox"
          :checked="activeStatuses.length === 0"
          class="accent-primary"
          @change="clearFilters"
        />
        <span class="text-sm text-gray-700 dark:text-gray-300">{{ $t('common.allStatuses') }}</span>
      </label>

      <div class="mt-2 space-y-0.5">
        <label
          v-for="s in allStatuses"
          :key="s.value"
          class="flex items-center gap-2 py-1.5 cursor-pointer rounded px-1 hover:bg-gray-50 dark:hover:bg-gray-700/30"
        >
          <input
            type="checkbox"
            :value="s.value"
            v-model="activeStatuses"
            class="accent-primary"
          />
          <span class="w-2 h-2 rounded-full shrink-0" :style="{ background: s.color }" />
          <span class="text-sm text-gray-700 dark:text-gray-300">{{ s.label }}</span>
          <span class="ml-auto text-xs text-gray-400">{{ countByStatus[s.value] ?? 0 }}</span>
        </label>
      </div>
    </aside>

    <!-- Main table area -->
    <div class="flex-1 flex flex-col overflow-hidden">
      <!-- Table header bar -->
      <div class="px-6 py-3 border-b border-gray-200 dark:border-gray-700 bg-white dark:bg-dispatch-dark-card flex items-center justify-between">
        <h1 class="font-semibold text-gray-900 dark:text-white">
          {{ $t('nav.tasks') }}
          <span class="ml-2 text-sm font-normal text-gray-400">{{ filteredTasks.length }}</span>
        </h1>
        <div v-if="loading" class="flex items-center gap-2 text-xs text-gray-400">
          <LoadingSpinner size="sm" />
          {{ $t('common.loading') }}
        </div>
      </div>

      <!-- Table -->
      <div class="flex-1 overflow-y-auto">
        <table class="w-full">
          <thead class="sticky top-0 z-10 table-header">
            <tr>
              <th class="table-cell w-16">{{ $t('task.id') }}</th>
              <th class="table-cell w-24">{{ $t('task.priority') }}</th>
              <th class="table-cell">{{ $t('task.title') }}</th>
              <th class="table-cell w-40">{{ $t('common.address') }}</th>
              <th class="table-cell w-36">{{ $t('task.assignee') }}</th>
              <th class="table-cell w-28">{{ $t('task.status') }}</th>
              <th class="table-cell w-32">{{ $t('task.deadline') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="task in filteredTasks"
              :key="task.id"
              class="table-row"
              @click="router.push('/tasks/' + task.id)"
            >
              <td class="table-cell font-mono text-gray-400 dark:text-gray-500 text-xs">#{{ task.id }}</td>
              <td class="table-cell"><PriorityBadge :priority="task.priority" /></td>
              <td class="table-cell font-medium text-gray-800 dark:text-gray-200 max-w-xs truncate">
                {{ task.title }}
              </td>
              <td class="table-cell text-gray-500 dark:text-gray-400 text-xs truncate max-w-xs">
                {{ equipmentMap[task.equipment_id]?.location ?? '-' }}
              </td>
              <td class="table-cell text-gray-600 dark:text-gray-400 text-xs truncate">
                {{ usersMap[task.assigned_to]?.full_name ?? '-' }}
              </td>
              <td class="table-cell">
                <StatusBadge :status="task.status" />
              </td>
              <td
                class="table-cell text-xs"
                :class="isDeadlineRed(task) ? 'text-status-overdue font-medium' : 'text-gray-400 dark:text-gray-500'"
              >
                {{ formatDate(task.deadline) }}
              </td>
            </tr>
          </tbody>
        </table>

        <EmptyState v-if="!loading && !filteredTasks.length" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import PriorityBadge from '@/components/ui/PriorityBadge.vue'
import { getTasks } from '@/api/tasks'
import { getUsers } from '@/api/users'
import { getEquipment } from '@/api/directories'
import { formatDate, isOverdue } from '@/utils/formatters'

const { t } = useI18n()
const router = useRouter()

const tasks = ref([])
const usersMap = ref({})
const equipmentMap = ref({})
const loading = ref(true)
const activeStatuses = ref([])

const STATUS_COLORS = {
  new: '#3B82F6', assigned: '#8B5CF6', in_progress: '#F59E0B',
  completed: '#10B981', approved: '#10B981', rejected: '#6B7280', overdue: '#EF4444',
}

const allStatuses = computed(() => [
  'new', 'assigned', 'in_progress', 'overdue', 'completed', 'approved', 'rejected',
].map((v) => ({ value: v, label: t(`status.${v}`), color: STATUS_COLORS[v] })))

const countByStatus = computed(() => {
  const m = {}
  for (const t of tasks.value) m[t.status] = (m[t.status] ?? 0) + 1
  return m
})

const filteredTasks = computed(() => {
  if (!activeStatuses.value.length) return tasks.value
  return tasks.value.filter((t) => activeStatuses.value.includes(t.status))
})

function clearFilters() {
  activeStatuses.value = []
}

function isDeadlineRed(task) {
  return task.status === 'overdue' || (task.deadline && isOverdue(task.deadline) && task.status !== 'completed' && task.status !== 'approved')
}

onMounted(async () => {
  try {
    const [tasksRes, usersRes, eqRes] = await Promise.all([
      getTasks({ limit: 200 }),
      getUsers({ limit: 200 }),
      getEquipment(),
    ])
    tasks.value = tasksRes.data
    for (const u of usersRes.data) usersMap.value[u.id] = u
    for (const e of eqRes.data) equipmentMap.value[e.id] = e
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})
</script>
