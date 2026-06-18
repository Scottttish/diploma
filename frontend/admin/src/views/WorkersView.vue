<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="page-title mb-0">{{ $t('nav.workers') }}</h1>
      <button class="btn-primary flex items-center gap-2" @click="openCreate">
        <PlusIcon class="w-4 h-4" />
        Добавить сотрудника
      </button>
    </div>

    <div class="card overflow-hidden">
      <div v-if="loading" class="py-8 flex justify-center">
        <LoadingSpinner />
      </div>

      <table v-else class="w-full">
        <thead class="table-header">
          <tr>
            <th class="table-cell">{{ $t('workers.name') }}</th>
            <th class="table-cell">{{ $t('workers.email') }}</th>
            <th class="table-cell w-28">{{ $t('workers.role') }}</th>
            <th class="table-cell">{{ $t('workers.skills') }}</th>
            <th class="table-cell w-20">{{ $t('workers.status') }}</th>
            <th class="table-cell w-32">{{ $t('workers.telegramId') }}</th>
            <th class="table-cell w-24">Действия</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="user.id" class="table-row">
            <td class="table-cell">
              <div class="flex items-center gap-2">
                <div class="w-7 h-7 rounded-full bg-primary/10 dark:bg-primary/20 text-primary text-xs font-semibold flex items-center justify-center shrink-0">
                  {{ getInitials(user.full_name) }}
                </div>
                <span class="font-medium text-gray-800 dark:text-gray-200">{{ user.full_name }}</span>
              </div>
            </td>
            <td class="table-cell text-gray-500 dark:text-gray-400 text-xs">{{ user.email }}</td>
            <td class="table-cell">
              <span class="text-xs px-2 py-0.5 rounded-full bg-primary/10 text-primary dark:bg-primary/20">
                {{ $t(`role.${user.role}`) }}
              </span>
            </td>
            <td class="table-cell text-xs text-gray-500 dark:text-gray-400">
              {{ skillsForUser(user.id) || $t('workers.noSkills') }}
            </td>
            <td class="table-cell">
              <span
                class="text-xs font-medium"
                :class="user.is_active ? 'text-status-completed' : 'text-status-rejected'"
              >
                {{ user.is_active ? $t('workers.active') : $t('workers.inactive') }}
              </span>
            </td>
            <td class="table-cell text-xs text-gray-400 dark:text-gray-500 font-mono">
              {{ user.telegram_id ?? '-' }}
            </td>
            <td class="table-cell">
              <div class="flex items-center gap-1">
                <button
                  class="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
                  title="Редактировать"
                  @click="openEdit(user)"
                >
                  <PencilIcon class="w-4 h-4" />
                </button>
                <button
                  class="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
                  title="Сменить пароль"
                  @click="openPasswordReset(user)"
                >
                  <KeyIcon class="w-4 h-4" />
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <EmptyState v-if="!loading && !users.length" />
    </div>

    <!-- Create User Modal -->
    <Modal v-model="showCreate" title="Новый сотрудник">
      <div class="space-y-4">
        <div>
          <label class="label">Полное имя</label>
          <input v-model="createForm.full_name" class="input" placeholder="Иванов Иван Иванович" />
        </div>
        <div>
          <label class="label">Email</label>
          <input v-model="createForm.email" type="email" class="input" placeholder="user@company.com" />
        </div>
        <div>
          <label class="label">Пароль</label>
          <input v-model="createForm.password" type="password" class="input" />
        </div>
        <div>
          <label class="label">Роль</label>
          <select v-model="createForm.role" class="input">
            <option value="worker">Исполнитель</option>
            <option value="dispatcher">Диспетчер</option>
            <option value="administrator">Администратор</option>
            <option value="manager">Менеджер</option>
          </select>
        </div>
        <div v-if="createForm.role === 'worker'">
          <label class="label">Навыки (типы услуг)</label>
          <div class="space-y-1 max-h-40 overflow-y-auto border border-gray-200 dark:border-gray-600 rounded p-2">
            <label
              v-for="st in serviceTypes"
              :key="st.id"
              class="flex items-center gap-2 text-sm cursor-pointer py-0.5"
            >
              <input
                type="checkbox"
                :value="st.id"
                v-model="createForm.skillIds"
                class="rounded"
              />
              {{ st.name }}
            </label>
          </div>
        </div>
        <p v-if="createMsg" class="text-xs" :class="createError ? 'text-status-overdue' : 'text-status-completed'">
          {{ createMsg }}
        </p>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showCreate = false">{{ $t('common.cancel') }}</button>
          <button class="btn-primary" :disabled="createSaving" @click="submitCreate">
            {{ createSaving ? 'Создание...' : 'Создать' }}
          </button>
        </div>
      </div>
    </Modal>

    <!-- Edit User Modal -->
    <Modal v-model="showEdit" title="Редактировать сотрудника">
      <div class="space-y-4">
        <div>
          <label class="label">Полное имя</label>
          <input v-model="editForm.full_name" class="input" />
        </div>
        <div>
          <label class="label">Роль</label>
          <select v-model="editForm.role" class="input">
            <option value="worker">Исполнитель</option>
            <option value="dispatcher">Диспетчер</option>
            <option value="administrator">Администратор</option>
            <option value="manager">Менеджер</option>
          </select>
        </div>
        <div>
          <label class="flex items-center gap-2 text-sm cursor-pointer">
            <input type="checkbox" v-model="editForm.is_active" class="rounded" />
            Активен
          </label>
        </div>
        <div v-if="editForm.role === 'worker'">
          <label class="label">Навыки (типы услуг)</label>
          <div class="space-y-1 max-h-40 overflow-y-auto border border-gray-200 dark:border-gray-600 rounded p-2">
            <label
              v-for="st in serviceTypes"
              :key="st.id"
              class="flex items-center gap-2 text-sm cursor-pointer py-0.5"
            >
              <input
                type="checkbox"
                :value="st.id"
                v-model="editForm.skillIds"
                class="rounded"
              />
              {{ st.name }}
            </label>
          </div>
        </div>
        <p v-if="editMsg" class="text-xs" :class="editError ? 'text-status-overdue' : 'text-status-completed'">
          {{ editMsg }}
        </p>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showEdit = false">{{ $t('common.cancel') }}</button>
          <button class="btn-primary" :disabled="editSaving" @click="submitEdit">
            {{ editSaving ? 'Сохранение...' : $t('common.save') }}
          </button>
        </div>
      </div>
    </Modal>

    <!-- Reset Password Modal -->
    <Modal v-model="showPwReset" title="Сброс пароля">
      <div class="space-y-4">
        <p class="text-sm text-gray-500 dark:text-gray-400">
          Установить новый пароль для <strong class="text-gray-800 dark:text-gray-200">{{ pwResetTarget?.full_name }}</strong>
        </p>
        <div>
          <label class="label">Новый пароль</label>
          <input v-model="newPassword" type="password" class="input" />
        </div>
        <p v-if="pwMsg" class="text-xs" :class="pwError ? 'text-status-overdue' : 'text-status-completed'">
          {{ pwMsg }}
        </p>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showPwReset = false">{{ $t('common.cancel') }}</button>
          <button class="btn-primary" :disabled="pwSaving" @click="submitPasswordReset">
            {{ pwSaving ? 'Сохранение...' : 'Сохранить' }}
          </button>
        </div>
      </div>
    </Modal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { PlusIcon, PencilIcon, KeyIcon } from '@heroicons/vue/24/outline'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import Modal from '@/components/ui/Modal.vue'
import { getUsers, createUser, updateUser, resetUserPassword } from '@/api/users'
import { getWorkerSkills, getServiceTypes, createWorkerSkill, deleteWorkerSkill } from '@/api/directories'
import { getInitials } from '@/utils/formatters'

const { t } = useI18n()

const users        = ref([])
const skillsMap    = ref({})
const serviceTypes = ref([])
const loading      = ref(true)

const showCreate  = ref(false)
const createSaving = ref(false)
const createMsg   = ref('')
const createError = ref(false)
const createForm  = ref({ full_name: '', email: '', password: '', role: 'worker', skillIds: [] })

const showEdit   = ref(false)
const editSaving = ref(false)
const editMsg    = ref('')
const editError  = ref(false)
const editTarget = ref(null)
const editForm   = ref({ full_name: '', role: 'worker', is_active: true, skillIds: [] })

const showPwReset    = ref(false)
const pwSaving       = ref(false)
const pwMsg          = ref('')
const pwError        = ref(false)
const pwResetTarget  = ref(null)
const newPassword    = ref('')

function skillsForUser(userId) {
  const skills = skillsMap.value[userId]
  if (!skills?.length) return ''
  return skills
    .map((s) => serviceTypes.value.find((st) => st.id === s.service_type_id)?.name ?? `#${s.service_type_id}`)
    .join(', ')
}

function buildSkillsMap(skillsList) {
  const map = {}
  for (const sk of skillsList) {
    if (!map[sk.worker_id]) map[sk.worker_id] = []
    map[sk.worker_id].push(sk)
  }
  return map
}

async function refreshSkills() {
  const res = await getWorkerSkills()
  skillsMap.value = buildSkillsMap(res.data)
}

// Compute the minimal set of add/delete calls needed to reach the desired skill set
async function syncSkills(workerId, selectedIds) {
  const current = skillsMap.value[workerId] ?? []
  const toAdd   = selectedIds.filter((id) => !current.find((s) => s.service_type_id === id))
  const toRemove = current.filter((s) => !selectedIds.includes(s.service_type_id))
  await Promise.all([
    ...toAdd.map((stId) => createWorkerSkill({ worker_id: workerId, service_type_id: stId })),
    ...toRemove.map((s) => deleteWorkerSkill(s.id)),
  ])
}

function openCreate() {
  createForm.value = { full_name: '', email: '', password: '', role: 'worker', skillIds: [] }
  createMsg.value  = ''
  createError.value = false
  showCreate.value = true
}

async function submitCreate() {
  createSaving.value = true
  createMsg.value    = ''
  try {
    const { data: newUser } = await createUser({
      full_name: createForm.value.full_name,
      email:     createForm.value.email,
      password:  createForm.value.password,
      role:      createForm.value.role,
    })
    if (createForm.value.role === 'worker' && createForm.value.skillIds.length) {
      await syncSkills(newUser.id, createForm.value.skillIds)
    }
    // Reload users and skills to reflect the new record
    const [usersRes, skillsRes] = await Promise.all([getUsers({ limit: 200 }), getWorkerSkills()])
    users.value     = usersRes.data
    skillsMap.value = buildSkillsMap(skillsRes.data)
    showCreate.value = false
  } catch (e) {
    createMsg.value   = e.response?.data?.detail ?? 'Ошибка создания'
    createError.value = true
  } finally {
    createSaving.value = false
  }
}

function openEdit(user) {
  editTarget.value = user
  editForm.value = {
    full_name: user.full_name,
    role:      user.role,
    is_active: user.is_active,
    skillIds:  (skillsMap.value[user.id] ?? []).map((s) => s.service_type_id),
  }
  editMsg.value   = ''
  editError.value = false
  showEdit.value  = true
}

async function submitEdit() {
  if (!editTarget.value) return
  editSaving.value = true
  editMsg.value    = ''
  try {
    await updateUser(editTarget.value.id, {
      full_name: editForm.value.full_name,
      role:      editForm.value.role,
      is_active: editForm.value.is_active,
    })
    if (editForm.value.role === 'worker') {
      await syncSkills(editTarget.value.id, editForm.value.skillIds)
    }
    const [usersRes, skillsRes] = await Promise.all([getUsers({ limit: 200 }), getWorkerSkills()])
    users.value     = usersRes.data
    skillsMap.value = buildSkillsMap(skillsRes.data)
    showEdit.value  = false
  } catch (e) {
    editMsg.value   = e.response?.data?.detail ?? 'Ошибка сохранения'
    editError.value = true
  } finally {
    editSaving.value = false
  }
}

function openPasswordReset(user) {
  pwResetTarget.value = user
  newPassword.value   = ''
  pwMsg.value         = ''
  pwError.value       = false
  showPwReset.value   = true
}

async function submitPasswordReset() {
  if (!pwResetTarget.value || !newPassword.value) return
  pwSaving.value = true
  pwMsg.value    = ''
  try {
    await resetUserPassword(pwResetTarget.value.id, newPassword.value)
    pwMsg.value    = 'Пароль обновлён'
    pwError.value  = false
    newPassword.value = ''
  } catch (e) {
    pwMsg.value   = e.response?.data?.detail ?? 'Ошибка'
    pwError.value = true
  } finally {
    pwSaving.value = false
  }
}

onMounted(async () => {
  try {
    const [usersRes, skillsRes, stRes] = await Promise.all([
      getUsers({ limit: 200 }),
      getWorkerSkills(),
      getServiceTypes(),
    ])
    users.value        = usersRes.data
    serviceTypes.value = stRes.data
    skillsMap.value    = buildSkillsMap(skillsRes.data)
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})
</script>
