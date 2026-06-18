<template>
  <div>
    <h1 class="page-title">{{ $t('nav.scheduling') }}</h1>

    <div v-if="loading" class="flex justify-center py-12">
      <LoadingSpinner />
    </div>

    <div v-else class="flex gap-4 overflow-x-auto pb-4">
      <!-- Unassigned column -->
      <div
        class="shrink-0 w-64 card overflow-hidden transition-shadow"
        :class="{ 'ring-2 ring-gray-400 shadow-lg': dragOverColumn === 'unassigned' }"
        @dragover.prevent="dragOverColumn = 'unassigned'"
        @dragleave="dragOverColumn = null"
        @drop.prevent="dropOnUnassigned"
      >
        <div class="bg-gray-600 text-white px-4 py-2.5 text-sm font-semibold">
          {{ $t('scheduling.unassigned') }}
          <span class="ml-2 text-white/60 font-normal text-xs">
            {{ unassignedTasks.length }}
          </span>
        </div>
        <div class="p-3 space-y-2 max-h-[calc(100vh-220px)] overflow-y-auto">
          <div
            v-for="task in unassignedTasks"
            :key="task.id"
            draggable="true"
            class="border-l-2 border-status-new pl-3 py-1.5 pr-2 bg-white dark:bg-gray-800/40 rounded-r text-sm cursor-grab active:cursor-grabbing hover:bg-gray-50 dark:hover:bg-gray-700/30 transition-colors select-none"
            :class="{ 'opacity-40': draggedTaskId === task.id }"
            @dragstart="startDrag(task)"
            @dragend="draggedTaskId = null"
            @click="navigateToTask(task.id)"
          >
            <div class="flex items-center justify-between gap-1">
              <span class="font-medium text-gray-700 dark:text-gray-200 truncate">{{ task.title }}</span>
              <span class="text-xs text-gray-400 shrink-0">#{{ task.id }}</span>
            </div>
            <div class="flex items-center gap-2 mt-1">
              <StatusBadge :status="task.status" />
              <PriorityBadge :priority="task.priority" />
            </div>
          </div>
          <EmptyState v-if="!unassignedTasks.length" :message="$t('scheduling.noTasks')" />
        </div>
      </div>

      <!-- Worker columns -->
      <div
        v-for="worker in workers"
        :key="worker.id"
        class="shrink-0 w-64 card overflow-hidden transition-shadow"
        :class="{ 'ring-2 ring-primary shadow-lg': dragOverColumn === worker.id }"
        @dragover.prevent="dragOverColumn = worker.id"
        @dragleave="dragOverColumn = null"
        @drop.prevent="dropOnWorker(worker.id)"
      >
        <div class="bg-primary text-white px-4 py-2.5 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <div class="w-6 h-6 rounded-full bg-white/20 text-white text-xs font-semibold flex items-center justify-center shrink-0">
              {{ getInitials(worker.full_name) }}
            </div>
            <span class="text-sm font-semibold truncate">{{ worker.full_name }}</span>
          </div>
          <span class="text-white/60 font-normal text-xs shrink-0">
            {{ tasksByWorker[worker.id]?.length ?? 0 }}
          </span>
        </div>
        <div class="p-3 space-y-2 max-h-[calc(100vh-220px)] overflow-y-auto">
          <div
            v-for="task in tasksByWorker[worker.id]"
            :key="task.id"
            draggable="true"
            class="border-l-2 pl-3 py-1.5 pr-2 bg-white dark:bg-gray-800/40 rounded-r text-sm cursor-grab active:cursor-grabbing hover:bg-gray-50 dark:hover:bg-gray-700/30 transition-colors select-none"
            :class="[statusBorderClass(task.status), { 'opacity-40': draggedTaskId === task.id }]"
            @dragstart="startDrag(task)"
            @dragend="draggedTaskId = null"
            @click="navigateToTask(task.id)"
          >
            <div class="flex items-center justify-between gap-1">
              <span class="font-medium text-gray-700 dark:text-gray-200 truncate">{{ task.title }}</span>
              <span class="text-xs text-gray-400 shrink-0">#{{ task.id }}</span>
            </div>
            <div class="flex items-center gap-2 mt-1">
              <StatusBadge :status="task.status" />
            </div>
          </div>
          <EmptyState v-if="!tasksByWorker[worker.id]?.length" :message="$t('scheduling.noTasks')" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import PriorityBadge from '@/components/ui/PriorityBadge.vue'
import { getTasks, assignTask, updateTask } from '@/api/tasks'
import { getUsers } from '@/api/users'
import { getInitials } from '@/utils/formatters'

const router = useRouter()
const loading = ref(true)
const tasks = ref([])
const workers = ref([])

const draggedTaskId = ref(null)
const dragOverColumn = ref(null)
// Prevent click navigation from firing after a drag-drop
let didDrop = false

const BORDER_CLASSES = {
  new: 'border-status-new',
  assigned: 'border-status-assigned',
  in_progress: 'border-status-inprogress',
  completed: 'border-status-completed',
  approved: 'border-status-approved',
  rejected: 'border-status-rejected',
  overdue: 'border-status-overdue',
}

function statusBorderClass(status) {
  return BORDER_CLASSES[status] ?? 'border-gray-300'
}

const unassignedTasks = computed(() =>
  tasks.value.filter((t) => !t.assigned_to && !['completed', 'approved', 'rejected'].includes(t.status))
)

const tasksByWorker = computed(() => {
  const map = {}
  for (const t of tasks.value) {
    if (t.assigned_to) {
      if (!map[t.assigned_to]) map[t.assigned_to] = []
      map[t.assigned_to].push(t)
    }
  }
  return map
})

function startDrag(task) {
  draggedTaskId.value = task.id
  didDrop = false
}

function navigateToTask(id) {
  if (!didDrop) router.push('/tasks/' + id)
  didDrop = false
}

async function dropOnWorker(workerId) {
  const id = draggedTaskId.value
  dragOverColumn.value = null
  draggedTaskId.value = null
  if (!id) return

  const task = tasks.value.find((t) => t.id === id)
  if (!task || task.assigned_to === workerId) return

  didDrop = true
  // Optimistic update
  task.assigned_to = workerId

  try {
    await assignTask(id, workerId)
  } catch (e) {
    console.error(e)
    // Rollback
    task.assigned_to = task.assigned_to === workerId ? null : task.assigned_to
  }
}

async function dropOnUnassigned() {
  const id = draggedTaskId.value
  dragOverColumn.value = null
  draggedTaskId.value = null
  if (!id) return

  const task = tasks.value.find((t) => t.id === id)
  if (!task || !task.assigned_to) return

  didDrop = true
  const previousAssignee = task.assigned_to
  // Optimistic update
  task.assigned_to = null

  try {
    await updateTask(id, { assigned_to: null })
  } catch (e) {
    console.error(e)
    // Rollback
    task.assigned_to = previousAssignee
  }
}

onMounted(async () => {
  try {
    const [tasksRes, usersRes] = await Promise.all([
      getTasks({ limit: 200 }),
      getUsers({ limit: 200 }),
    ])
    tasks.value = tasksRes.data
    workers.value = usersRes.data.filter((u) => u.role === 'worker' && u.is_active)
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})
</script>
