<template>
  <div>
    <!-- Back + Loading -->
    <div v-if="loading" class="flex justify-center py-12">
      <LoadingSpinner size="lg" />
    </div>

    <template v-else-if="task">
      <!-- Work order header -->
      <div class="flex flex-wrap items-center gap-3 mb-6">
        <button
          class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
          @click="router.back()"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <h1 class="text-xl font-semibold text-gray-900 dark:text-white">
          {{ $t('task.workOrder') }} #{{ task.id }}
        </h1>
        <StatusBadge :status="task.status" />
        <PriorityBadge :priority="task.priority" />
        <span class="ml-auto text-xs text-gray-400">{{ formatDate(task.created_at) }}</span>
      </div>

      <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <!-- Task details (left 2 cols) -->
        <div class="xl:col-span-2 space-y-4">
          <div class="card p-5 space-y-4">
            <h2 class="font-semibold text-gray-800 dark:text-gray-200 border-b border-gray-100 dark:border-gray-700 pb-2">
              {{ task.title }}
            </h2>

            <div class="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p class="label">{{ $t('task.serviceType') }}</p>
                <p class="text-gray-700 dark:text-gray-300">
                  {{ task.service_type_id ? `#${task.service_type_id}` : '-' }}
                </p>
              </div>
              <div>
                <p class="label">{{ $t('task.equipment') }}</p>
                <p class="text-gray-700 dark:text-gray-300">
                  {{ equipment?.name ?? (task.equipment_id ? `#${task.equipment_id}` : '-') }}
                </p>
              </div>
              <div>
                <p class="label">{{ $t('task.reactionDeadline') }}</p>
                <p class="text-gray-700 dark:text-gray-300">{{ formatDate(task.reaction_deadline) }}</p>
              </div>
              <div>
                <p class="label">{{ $t('task.completionDeadline') }}</p>
                <p
                  class="font-medium"
                  :class="isOverdue(task.completion_deadline) && !['completed','approved'].includes(task.status) ? 'text-status-overdue' : 'text-gray-700 dark:text-gray-300'"
                >
                  {{ formatDate(task.completion_deadline) }}
                </p>
              </div>
              <div>
                <p class="label">{{ $t('task.createdBy') }}</p>
                <p class="text-gray-700 dark:text-gray-300">
                  {{ usersMap[task.created_by]?.full_name ?? `#${task.created_by}` }}
                </p>
              </div>
              <div>
                <p class="label">{{ $t('task.assignee') }}</p>
                <p class="text-gray-700 dark:text-gray-300">
                  {{ task.assigned_to ? (usersMap[task.assigned_to]?.full_name ?? `#${task.assigned_to}`) : '-' }}
                </p>
              </div>
            </div>

            <div v-if="task.description">
              <p class="label">{{ $t('task.description') }}</p>
              <p class="text-sm text-gray-700 dark:text-gray-300 whitespace-pre-wrap leading-relaxed">
                {{ task.description }}
              </p>
            </div>
          </div>

          <!-- File upload -->
          <div class="card p-5">
            <p class="label mb-3">{{ $t('task.files') }}</p>
            <div
              class="border-2 border-dashed border-gray-200 dark:border-gray-700 rounded-lg p-6 text-center hover:border-primary/40 transition-colors cursor-pointer"
              @click="fileInput?.click()"
              @dragover.prevent
              @drop.prevent="handleDrop"
            >
              <svg class="w-8 h-8 text-gray-300 dark:text-gray-600 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
              </svg>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ $t('task.uploadArea') }}</p>
              <input ref="fileInput" type="file" class="hidden" @change="handleFileChange" />
            </div>
            <p v-if="uploadMsg" class="text-xs mt-2" :class="uploadError ? 'text-status-overdue' : 'text-status-completed'">
              {{ uploadMsg }}
            </p>
          </div>
        </div>

        <!-- Right panel: actions + history -->
        <div class="space-y-4">
          <!-- Action buttons -->
          <div class="card p-5 space-y-3">
            <h3 class="font-semibold text-sm text-gray-700 dark:text-gray-300 mb-1">Действия</h3>

            <button
              v-if="canAssign"
              class="w-full py-3 rounded font-semibold text-sm bg-primary text-white hover:bg-primary/90 transition-colors"
              @click="showAssignModal = true"
            >
              {{ $t('task.assign') }}
            </button>

            <button
              v-if="canStartWork"
              class="w-full py-3 rounded font-semibold text-sm bg-status-assigned text-white hover:opacity-90 transition-colors"
              @click="updateStatus('in_progress')"
            >
              Начать работу
            </button>

            <button
              v-if="canComplete"
              class="w-full py-3 rounded font-semibold text-sm bg-status-inprogress text-white hover:opacity-90 transition-colors"
              @click="updateStatus('completed')"
            >
              {{ $t('task.complete') }}
            </button>

            <template v-if="canReview">
              <button
                class="w-full py-3 rounded font-semibold text-sm bg-status-completed text-white hover:opacity-90 transition-colors"
                @click="submitReview('approved')"
              >
                {{ $t('task.approve') }}
              </button>
              <button
                class="w-full py-3 rounded font-semibold text-sm border-2 border-status-overdue text-status-overdue hover:bg-status-overdue hover:text-white transition-colors"
                @click="showRejectModal = true"
              >
                {{ $t('task.reject') }}
              </button>
            </template>

            <p v-if="actionMsg" class="text-xs text-center" :class="actionError ? 'text-status-overdue' : 'text-status-completed'">
              {{ actionMsg }}
            </p>
          </div>

          <!-- History timeline -->
          <div class="card p-5">
            <h3 class="font-semibold text-sm text-gray-700 dark:text-gray-300 mb-4">
              {{ $t('task.history') }}
            </h3>
            <div v-if="task.history?.length" class="space-y-3">
              <div
                v-for="entry in task.history"
                :key="entry.id"
                class="flex gap-3"
              >
                <div class="flex flex-col items-center">
                  <div class="w-2 h-2 rounded-full bg-gray-300 dark:bg-gray-600 mt-1.5 shrink-0" />
                  <div class="w-px flex-1 bg-gray-100 dark:bg-gray-700 mt-1" />
                </div>
                <div class="pb-3 min-w-0">
                  <p class="text-xs text-gray-400">{{ formatDate(entry.changed_at) }}</p>
                  <p class="text-xs mt-0.5">
                    <span class="text-gray-500">{{ entry.old_status ?? '-' }}</span>
                    <span class="mx-1 text-gray-300">→</span>
                    <span class="font-medium text-gray-700 dark:text-gray-300">{{ entry.new_status }}</span>
                  </p>
                  <p v-if="entry.comment" class="text-xs text-gray-500 dark:text-gray-400 mt-0.5 italic">
                    {{ entry.comment }}
                  </p>
                </div>
              </div>
            </div>
            <EmptyState v-else :message="$t('task.noHistory')" />
          </div>
        </div>
      </div>
    </template>

    <div v-else class="text-center py-12 text-gray-400">Заявка не найдена</div>

    <!-- Assign Modal -->
    <Modal v-model="showAssignModal" :title="$t('task.assign')">
      <div class="space-y-4">
        <div>
          <label class="label">{{ $t('workers.name') }}</label>
          <input
            v-model="workerSearch"
            class="input mb-2"
            placeholder="Поиск сотрудника..."
          />

          <select v-model="selectedWorker" class="input">
            <option value="" disabled>Выберите исполнителя</option>
            <option
              v-for="w in filteredWorkers"
              :key="w.id"
              :value="w.id"
            >
              {{ w.full_name }} ({{ w.email }})
            </option>
          </select>
        </div>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showAssignModal = false">{{ $t('common.cancel') }}</button>
          <button class="btn-primary" :disabled="!selectedWorker" @click="doAssign">
            {{ $t('task.assign') }}
          </button>
        </div>
      </div>
    </Modal>

    <!-- Reject Modal -->
    <Modal v-model="showRejectModal" :title="$t('task.reject')">
      <div class="space-y-4">
        <div>
          <label class="label">Причина отклонения</label>
          <textarea v-model="rejectComment" class="input h-24 resize-none" placeholder="Укажите причину..." />
        </div>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showRejectModal = false">{{ $t('common.cancel') }}</button>
          <button class="btn-primary" @click="submitReview('rejected')">{{ $t('task.reject') }}</button>
        </div>
      </div>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import PriorityBadge from '@/components/ui/PriorityBadge.vue'
import Modal from '@/components/ui/Modal.vue'
import { getTask, updateTask, assignTask, createTaskReview, uploadTaskFile } from '@/api/tasks'
import { getUsers } from '@/api/users'
import { getEquipment } from '@/api/directories'
import { useAuthStore } from '@/stores/auth'
import { formatDate, isOverdue } from '@/utils/formatters'

const route = useRoute()
const router = useRouter()
const { t } = useI18n()
const authStore = useAuthStore()

const taskId = Number(route.params.id)
const task = ref(null)
const loading = ref(true)
const usersMap = ref({})
const workers = ref([])
const equipment = ref(null)

const showAssignModal = ref(false)
const showRejectModal = ref(false)
const selectedWorker = ref(null)
const rejectComment = ref('')
const actionMsg = ref('')
const actionError = ref(false)

const fileInput = ref(null)
const uploadMsg = ref('')
const uploadError = ref(false)

const canAssign = computed(() =>
  ['new', 'assigned', 'overdue', 'rejected'].includes(task.value?.status) && authStore.isDispatcher
)
const canStartWork = computed(() =>
  task.value?.status === 'assigned' && task.value?.assigned_to === authStore.user?.id
)
const canComplete = computed(() =>
  task.value?.status === 'in_progress' && task.value?.assigned_to === authStore.user?.id
)
const canReview = computed(() =>
  task.value?.status === 'completed' && authStore.isAdministrator
)


const workerSearch = ref('')

const filteredWorkers = computed(() => {
  const q = workerSearch.value.toLowerCase()
  return workers.value.filter(w =>
    `${w.full_name} ${w.email}`.toLowerCase().includes(q)
  )
})

async function updateStatus(status) {
  try {
    const { data } = await updateTask(taskId, { status })
    task.value = data
    actionMsg.value = 'Статус обновлён'
    actionError.value = false
  } catch (e) {
    actionMsg.value = e.response?.data?.detail ?? 'Ошибка'
    actionError.value = true
  }
}

async function doAssign() {
  if (!selectedWorker.value) return
  try {
    const { data } = await assignTask(taskId, selectedWorker.value)
    task.value = data
    showAssignModal.value = false
    actionMsg.value = 'Исполнитель назначен'
    actionError.value = false
  } catch (e) {
    actionMsg.value = e.response?.data?.detail ?? 'Ошибка назначения'
    actionError.value = true
  }
}

async function submitReview(decision) {
  try {
    const { data } = await createTaskReview(
      taskId,
      decision,
      decision === 'rejected' ? rejectComment.value : null
    )
    task.value = data
    showRejectModal.value = false
    actionMsg.value = decision === 'approved' ? 'Работа принята' : 'Заявка отклонена'
    actionError.value = false
  } catch (e) {
    actionMsg.value = e.response?.data?.detail ?? 'Ошибка'
    actionError.value = true
  }
}

async function handleFileChange(e) {
  const file = e.target.files?.[0]
  if (!file) return
  try {
    await uploadTaskFile(taskId, file)
    uploadMsg.value = `Файл "${file.name}" прикреплён`
    uploadError.value = false
  } catch {
    uploadMsg.value = 'Ошибка загрузки файла'
    uploadError.value = true
  }
}

function handleDrop(e) {
  const file = e.dataTransfer.files?.[0]
  if (file && fileInput.value) {
    const dt = new DataTransfer()
    dt.items.add(file)
    fileInput.value.files = dt.files
    handleFileChange({ target: fileInput.value })
  }
}

onMounted(async () => {
  try {
    const [taskRes, usersRes] = await Promise.all([
      getTask(taskId),
      getUsers({ limit: 200 }),
    ])
    task.value = taskRes.data
    for (const u of usersRes.data) usersMap.value[u.id] = u
    workers.value = usersRes.data.filter((u) => u.role === 'worker' && u.is_active)

    if (task.value?.equipment_id) {
      const eqRes = await getEquipment()
      equipment.value = eqRes.data.find((e) => e.id === task.value.equipment_id) ?? null
    }
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})

watch(showAssignModal, (open) => {
  if (open) {
    selectedWorker.value = task.value?.assigned_to ?? null
    workerSearch.value = ''
  } else {
    selectedWorker.value = null
  }
})

</script>
