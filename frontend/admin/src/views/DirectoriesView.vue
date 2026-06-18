<template>
  <div>
    <h1 class="page-title">{{ t('nav.directories') }}</h1>

    <!-- Tab bar -->
    <div class="flex gap-1 mb-6 border-b border-gray-200 dark:border-gray-700">
      <button
        v-for="tab in tabs"
        :key="tab.key"
        class="px-4 py-2.5 text-sm font-medium border-b-2 transition-colors"
        :class="activeTab === tab.key
          ? 'border-primary text-primary'
          : 'border-transparent text-gray-500 hover:text-gray-700 dark:hover:text-gray-300'"
        @click="activeTab = tab.key"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- Service Types -->
    <div v-show="activeTab === 'service-types'">
      <div class="flex items-center justify-between mb-4">
        <p class="text-sm text-gray-500 dark:text-gray-400">{{ serviceTypes.length }} типов услуг</p>
        <button class="btn-primary flex items-center gap-2" @click="openCreateST">
          <PlusIcon class="w-4 h-4" /> Добавить
        </button>
      </div>
      <div class="card overflow-hidden">
        <div v-if="loading" class="py-8 flex justify-center"><LoadingSpinner /></div>
        <table v-else class="w-full">
          <thead class="table-header">
            <tr>
              <th class="table-cell text-xs text-gray-400">{{ t('directories.key') }}</th>
              <th class="table-cell">Название</th>
              <th class="table-cell">Описание</th>
              <th class="table-cell w-24">{{ t('directories.isActive') }}</th>
              <th class="table-cell w-20"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="st in serviceTypes" :key="st.id" class="table-row">
              <td class="table-cell text-xs font-mono text-gray-400 dark:text-gray-500">{{ st.key }}</td>
              <td class="table-cell font-medium text-gray-800 dark:text-gray-200">{{ st.name }}</td>
              <td class="table-cell text-sm text-gray-500 dark:text-gray-400">{{ st.description || '-' }}</td>
              <td class="table-cell">
                <span
                  class="text-xs font-medium"
                  :class="st.is_active ? 'text-status-completed' : 'text-gray-400'"
                >
                  {{ st.is_active ? t('directories.isActive') : t('directories.inactive') }}
                </span>
              </td>
              <td class="table-cell">
                <div class="flex items-center gap-1">
                  <button
                    class="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-400 hover:text-gray-600 transition-colors"
                    @click="openEditST(st)"
                  >
                    <PencilIcon class="w-4 h-4" />
                  </button>
                  <button
                    class="p-1.5 rounded hover:bg-red-50 dark:hover:bg-red-900/20 text-gray-400 hover:text-red-500 transition-colors"
                    @click="deleteSTFn(st)"
                  >
                    <TrashIcon class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <EmptyState v-if="!loading && !serviceTypes.length" />
      </div>
    </div>

    <!-- Equipment -->
    <div v-show="activeTab === 'equipment'">
      <div class="flex items-center justify-between mb-4">
        <p class="text-sm text-gray-500 dark:text-gray-400">{{ equipment.length }} единиц оборудования</p>
        <button class="btn-primary flex items-center gap-2" @click="openCreateEq">
          <PlusIcon class="w-4 h-4" /> Добавить
        </button>
      </div>
      <div class="card overflow-hidden">
        <div v-if="loading" class="py-8 flex justify-center"><LoadingSpinner /></div>
        <table v-else class="w-full">
          <thead class="table-header">
            <tr>
              <th class="table-cell text-xs text-gray-400">{{ t('directories.key') }}</th>
              <th class="table-cell">Название</th>
              <th class="table-cell w-32">{{ t('directories.typeName') }}</th>
              <th class="table-cell">Расположение</th>
              <th class="table-cell">Тип услуги</th>
              <th class="table-cell w-20"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="eq in equipment" :key="eq.id" class="table-row">
              <td class="table-cell text-xs font-mono text-gray-400 dark:text-gray-500">{{ eq.key }}</td>
              <td class="table-cell font-medium text-gray-800 dark:text-gray-200">{{ eq.name }}</td>
              <td class="table-cell text-sm text-gray-500 dark:text-gray-400">{{ eq.type }}</td>
              <td class="table-cell text-sm text-gray-500 dark:text-gray-400">{{ eq.location || '-' }}</td>
              <td class="table-cell text-sm text-gray-500 dark:text-gray-400">
                {{ stMap[eq.service_type_id]?.name ?? '-' }}
              </td>
              <td class="table-cell">
                <div class="flex items-center gap-1">
                  <button
                    class="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-400 hover:text-gray-600 transition-colors"
                    @click="openEditEq(eq)"
                  >
                    <PencilIcon class="w-4 h-4" />
                  </button>
                  <button
                    class="p-1.5 rounded hover:bg-red-50 dark:hover:bg-red-900/20 text-gray-400 hover:text-red-500 transition-colors"
                    @click="deleteEqFn(eq)"
                  >
                    <TrashIcon class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <EmptyState v-if="!loading && !equipment.length" />
      </div>
    </div>

    <!-- SLA Rules -->
    <div v-show="activeTab === 'sla-rules'">
      <div class="flex items-center justify-between mb-4">
        <p class="text-sm text-gray-500 dark:text-gray-400">{{ slaRules.length }} правил SLA</p>
        <button class="btn-primary flex items-center gap-2" @click="openCreateSLA">
          <PlusIcon class="w-4 h-4" /> Добавить
        </button>
      </div>
      <div class="card overflow-hidden">
        <div v-if="loading" class="py-8 flex justify-center"><LoadingSpinner /></div>
        <table v-else class="w-full">
          <thead class="table-header">
            <tr>
              <th class="table-cell">Тип услуги</th>
              <th class="table-cell w-32">Приоритет</th>
              <th class="table-cell w-32">Реакция (мин)</th>
              <th class="table-cell w-36">Выполнение (мин)</th>
              <th class="table-cell w-20"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="rule in slaRules" :key="rule.id" class="table-row">
              <td class="table-cell font-medium text-gray-800 dark:text-gray-200">
                {{ stMap[rule.service_type_id]?.name ?? `#${rule.service_type_id}` }}
              </td>
              <td class="table-cell">
                <span class="text-xs px-2 py-0.5 rounded-full bg-primary/10 text-primary">
                  {{ priorityLabel(rule.priority) }}
                </span>
              </td>
              <td class="table-cell text-sm text-gray-600 dark:text-gray-400">{{ rule.reaction_minutes }}</td>
              <td class="table-cell text-sm text-gray-600 dark:text-gray-400">{{ rule.completion_minutes }}</td>
              <td class="table-cell">
                <div class="flex items-center gap-1">
                  <button
                    class="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-400 hover:text-gray-600 transition-colors"
                    @click="openEditSLA(rule)"
                  >
                    <PencilIcon class="w-4 h-4" />
                  </button>
                  <button
                    class="p-1.5 rounded hover:bg-red-50 dark:hover:bg-red-900/20 text-gray-400 hover:text-red-500 transition-colors"
                    @click="deleteSLAFn(rule)"
                  >
                    <TrashIcon class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <EmptyState v-if="!loading && !slaRules.length" />
      </div>
    </div>

    <!-- ── Service Type Modals ─────────────────────────────────────── -->
    <Modal v-model="showCreateST" title="Новый тип услуги">
      <div class="space-y-4">
        <div>
          <label class="label">{{ t('directories.key') }}</label>
          <input v-model="stForm.key" class="input font-mono" placeholder="emergency_repair" />
        </div>
        <TranslationTabs
          :form="stForm"
          :langs="LANGS"
          :fields="['name', 'description']"
          :labels="{ name: 'Название', description: 'Описание' }"
          :multiline="['description']"
        />
        <p v-if="stMsg" class="text-xs" :class="stError ? 'text-status-overdue' : 'text-status-completed'">{{ stMsg }}</p>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showCreateST = false">Отмена</button>
          <button class="btn-primary" :disabled="stSaving" @click="submitCreateST">
            {{ stSaving ? 'Создание...' : 'Создать' }}
          </button>
        </div>
      </div>
    </Modal>

    <Modal v-model="showEditST" title="Редактировать тип услуги">
      <div class="space-y-4">
        <div>
          <label class="label">{{ t('directories.key') }}</label>
          <input v-model="stForm.key" class="input font-mono" />
        </div>
        <TranslationTabs
          :form="stForm"
          :langs="LANGS"
          :fields="['name', 'description']"
          :labels="{ name: 'Название', description: 'Описание' }"
          :multiline="['description']"
        />
        <div class="flex items-center gap-2">
          <input type="checkbox" v-model="stForm.is_active" id="st-active" class="w-4 h-4 accent-primary" />
          <label for="st-active" class="label mb-0">{{ t('directories.isActive') }}</label>
        </div>
        <p v-if="stMsg" class="text-xs" :class="stError ? 'text-status-overdue' : 'text-status-completed'">{{ stMsg }}</p>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showEditST = false">Отмена</button>
          <button class="btn-primary" :disabled="stSaving" @click="submitEditST">
            {{ stSaving ? 'Сохранение...' : 'Сохранить' }}
          </button>
        </div>
      </div>
    </Modal>

    <!-- ── Equipment Modals ───────────────────────────────────────── -->
    <Modal v-model="showCreateEq" title="Новое оборудование">
      <div class="space-y-4">
        <div>
          <label class="label">{{ t('directories.key') }}</label>
          <input v-model="eqForm.key" class="input font-mono" placeholder="boiler_unit_1" />
        </div>
        <TranslationTabs
          :form="eqForm"
          :langs="LANGS"
          :fields="['name', 'type_name']"
          :labels="{ name: 'Название', type_name: t('directories.typeName') }"
        />
        <div>
          <label class="label">Расположение</label>
          <input v-model="eqForm.location" class="input" />
        </div>
        <div>
          <label class="label">Тип услуги</label>
          <select v-model="eqForm.service_type_id" class="input">
            <option :value="null">- не выбран -</option>
            <option v-for="st in serviceTypes" :key="st.id" :value="st.id">{{ st.name }}</option>
          </select>
        </div>
        <p v-if="eqMsg" class="text-xs" :class="eqError ? 'text-status-overdue' : 'text-status-completed'">{{ eqMsg }}</p>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showCreateEq = false">Отмена</button>
          <button class="btn-primary" :disabled="eqSaving" @click="submitCreateEq">
            {{ eqSaving ? 'Создание...' : 'Создать' }}
          </button>
        </div>
      </div>
    </Modal>

    <Modal v-model="showEditEq" title="Редактировать оборудование">
      <div class="space-y-4">
        <div>
          <label class="label">{{ t('directories.key') }}</label>
          <input v-model="eqForm.key" class="input font-mono" />
        </div>
        <TranslationTabs
          :form="eqForm"
          :langs="LANGS"
          :fields="['name', 'type_name']"
          :labels="{ name: 'Название', type_name: t('directories.typeName') }"
        />
        <div>
          <label class="label">Расположение</label>
          <input v-model="eqForm.location" class="input" />
        </div>
        <div>
          <label class="label">Тип услуги</label>
          <select v-model="eqForm.service_type_id" class="input">
            <option :value="null">- не выбран -</option>
            <option v-for="st in serviceTypes" :key="st.id" :value="st.id">{{ st.name }}</option>
          </select>
        </div>
        <div class="flex items-center gap-2">
          <input type="checkbox" v-model="eqForm.is_active" id="eq-active" class="w-4 h-4 accent-primary" />
          <label for="eq-active" class="label mb-0">{{ t('directories.isActive') }}</label>
        </div>
        <p v-if="eqMsg" class="text-xs" :class="eqError ? 'text-status-overdue' : 'text-status-completed'">{{ eqMsg }}</p>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showEditEq = false">Отмена</button>
          <button class="btn-primary" :disabled="eqSaving" @click="submitEditEq">
            {{ eqSaving ? 'Сохранение...' : 'Сохранить' }}
          </button>
        </div>
      </div>
    </Modal>

    <!-- ── SLA Modals ─────────────────────────────────────────────── -->
    <Modal v-model="showCreateSLA" title="Новое правило SLA">
      <div class="space-y-4">
        <div>
          <label class="label">Тип услуги</label>
          <select v-model="slaForm.service_type_id" class="input">
            <option :value="null" disabled>- выберите -</option>
            <option v-for="st in serviceTypes" :key="st.id" :value="st.id">{{ st.name }}</option>
          </select>
        </div>
        <div>
          <label class="label">Приоритет</label>
          <select v-model="slaForm.priority" class="input">
            <option :value="1">1 - Критичный</option>
            <option :value="2">2 - Высокий</option>
            <option :value="3">3 - Нормальный</option>
            <option :value="4">4 - Низкий</option>
          </select>
        </div>
        <div>
          <label class="label">Реакция (минут)</label>
          <input v-model.number="slaForm.reaction_minutes" type="number" min="1" class="input" />
        </div>
        <div>
          <label class="label">Выполнение (минут)</label>
          <input v-model.number="slaForm.completion_minutes" type="number" min="1" class="input" />
        </div>
        <p v-if="slaMsg" class="text-xs" :class="slaError ? 'text-status-overdue' : 'text-status-completed'">{{ slaMsg }}</p>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showCreateSLA = false">Отмена</button>
          <button class="btn-primary" :disabled="slaSaving" @click="submitCreateSLA">
            {{ slaSaving ? 'Создание...' : 'Создать' }}
          </button>
        </div>
      </div>
    </Modal>

    <Modal v-model="showEditSLA" title="Редактировать правило SLA">
      <div class="space-y-4">
        <div class="grid grid-cols-2 gap-3 text-sm text-gray-500 dark:text-gray-400">
          <div>
            <p class="label">Тип услуги</p>
            <p class="text-gray-700 dark:text-gray-300 font-medium">{{ stMap[slaEditTarget?.service_type_id]?.name ?? '-' }}</p>
          </div>
          <div>
            <p class="label">Приоритет</p>
            <p class="text-gray-700 dark:text-gray-300 font-medium">{{ priorityLabel(slaEditTarget?.priority) }}</p>
          </div>
        </div>
        <div>
          <label class="label">Реакция (минут)</label>
          <input v-model.number="slaForm.reaction_minutes" type="number" min="1" class="input" />
        </div>
        <div>
          <label class="label">Выполнение (минут)</label>
          <input v-model.number="slaForm.completion_minutes" type="number" min="1" class="input" />
        </div>
        <p v-if="slaMsg" class="text-xs" :class="slaError ? 'text-status-overdue' : 'text-status-completed'">{{ slaMsg }}</p>
        <div class="flex gap-3 justify-end">
          <button class="btn-ghost" @click="showEditSLA = false">Отмена</button>
          <button class="btn-primary" :disabled="slaSaving" @click="submitEditSLA">
            {{ slaSaving ? 'Сохранение...' : 'Сохранить' }}
          </button>
        </div>
      </div>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, defineComponent, h } from 'vue'
import { useI18n } from 'vue-i18n'
import { PlusIcon, PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import Modal from '@/components/ui/Modal.vue'
import {
  getServiceTypes, createServiceType, updateServiceType, deleteServiceType,
  getEquipment, createEquipment, updateEquipment, deleteEquipment,
  getSlaRules, createSlaRule, updateSlaRule, deleteSlaRule,
} from '@/api/directories'

const { t, locale } = useI18n()

const LANGS = ['en', 'ru', 'kk']
const LANG_LABELS = { en: 'EN', ru: 'RU', kk: 'ҚЗ' }

// ── Inline TranslationTabs component ─────────────────────────────────────────
const TranslationTabs = defineComponent({
  name: 'TranslationTabs',
  props: {
    form: { type: Object, required: true },
    langs: { type: Array, required: true },
    fields: { type: Array, required: true },
    labels: { type: Object, required: true },
    multiline: { type: Array, default: () => [] },
  },
  setup(props) {
    return () => h('div', [
      // Tab bar
      h('div', { class: 'flex gap-1 border-b border-gray-200 dark:border-gray-700 mb-3' },
        props.langs.map(lang =>
          h('button', {
            type: 'button',
            class: [
              'px-3 py-1.5 text-xs font-medium border-b-2 transition-colors',
              props.form.activeLang === lang
                ? 'border-primary text-primary'
                : 'border-transparent text-gray-400 hover:text-gray-600 dark:hover:text-gray-300',
            ].join(' '),
            onClick: () => { props.form.activeLang = lang },
          }, LANG_LABELS[lang])
        )
      ),
      // Fields for active lang
      h('div', { class: 'space-y-3' },
        props.fields.map(field =>
          h('div', [
            h('label', { class: 'label' }, props.labels[field] ?? field),
            props.multiline.includes(field)
              ? h('textarea', {
                  class: 'input h-20 resize-none',
                  value: props.form.translations[props.form.activeLang][field] ?? '',
                  onInput: (e) => { props.form.translations[props.form.activeLang][field] = e.target.value },
                })
              : h('input', {
                  class: 'input',
                  value: props.form.translations[props.form.activeLang][field] ?? '',
                  onInput: (e) => { props.form.translations[props.form.activeLang][field] = e.target.value },
                }),
          ])
        )
      ),
    ])
  },
})

// ── Shared helpers ────────────────────────────────────────────────────────────

const tabs = [
  { key: 'service-types', label: 'Типы услуг' },
  { key: 'equipment',     label: 'Оборудование' },
  { key: 'sla-rules',     label: 'Правила SLA' },
]
const activeTab = ref('service-types')
const loading   = ref(true)

const serviceTypes = ref([])
const equipment    = ref([])
const slaRules     = ref([])

const stMap = computed(() => {
  const m = {}
  for (const st of serviceTypes.value) m[st.id] = st
  return m
})

const PRIORITY_LABELS = { 1: 'Критичный', 2: 'Высокий', 3: 'Нормальный', 4: 'Низкий' }
function priorityLabel(p) { return PRIORITY_LABELS[p] ?? `P${p}` }

function emptyTranslations() {
  return Object.fromEntries(LANGS.map(l => [l, { name: '', description: '', type_name: '' }]))
}

function translationsFromApi(apiTranslations) {
  const result = emptyTranslations()
  for (const tr of (apiTranslations ?? [])) {
    if (result[tr.lang]) {
      result[tr.lang].name        = tr.name ?? ''
      result[tr.lang].description = tr.description ?? ''
      result[tr.lang].type_name   = tr.type_name ?? ''
    }
  }
  return result
}

function buildTranslationPayload(translations, fields) {
  return LANGS
    .map(l => ({ lang: l, ...Object.fromEntries(fields.map(f => [f, translations[l][f] || null])) }))
    .filter(tr => tr.name?.trim())
}

// ── Service Type state ────────────────────────────────────────────────────────

const showCreateST = ref(false)
const showEditST   = ref(false)
const stEditTarget = ref(null)
const stSaving     = ref(false)
const stMsg        = ref('')
const stError      = ref(false)
const stForm       = ref({ key: '', is_active: true, activeLang: 'ru', translations: emptyTranslations() })

function openCreateST() {
  stForm.value = { key: '', is_active: true, activeLang: 'ru', translations: emptyTranslations() }
  stMsg.value  = ''
  stError.value = false
  showCreateST.value = true
}
function openEditST(st) {
  stEditTarget.value = st
  stForm.value = {
    key: st.key,
    is_active: st.is_active,
    activeLang: 'ru',
    translations: translationsFromApi(st.translations),
  }
  stMsg.value   = ''
  stError.value = false
  showEditST.value = true
}
async function submitCreateST() {
  stSaving.value = true
  stMsg.value    = ''
  stError.value  = false
  try {
    const payload = {
      key: stForm.value.key,
      translations: buildTranslationPayload(stForm.value.translations, ['name', 'description']),
    }
    const { data } = await createServiceType(payload)
    serviceTypes.value.push(data)
    showCreateST.value = false
  } catch (e) {
    stMsg.value   = e.response?.data?.detail ?? 'Ошибка'
    stError.value = true
  } finally {
    stSaving.value = false
  }
}
async function submitEditST() {
  if (!stEditTarget.value) return
  stSaving.value = true
  stMsg.value    = ''
  stError.value  = false
  try {
    const payload = {
      key:          stForm.value.key,
      is_active:    stForm.value.is_active,
      translations: buildTranslationPayload(stForm.value.translations, ['name', 'description']),
    }
    const { data } = await updateServiceType(stEditTarget.value.id, payload)
    const idx = serviceTypes.value.findIndex((s) => s.id === data.id)
    if (idx !== -1) serviceTypes.value[idx] = data
    showEditST.value = false
  } catch (e) {
    stMsg.value   = e.response?.data?.detail ?? 'Ошибка'
    stError.value = true
  } finally {
    stSaving.value = false
  }
}
async function deleteSTFn(st) {
  if (!confirm(t('directories.confirmDelete'))) return
  try {
    await deleteServiceType(st.id)
    serviceTypes.value = serviceTypes.value.filter((s) => s.id !== st.id)
  } catch (e) {
    alert(e.response?.data?.detail ?? 'Ошибка')
  }
}

// ── Equipment state ───────────────────────────────────────────────────────────

const showCreateEq = ref(false)
const showEditEq   = ref(false)
const eqEditTarget = ref(null)
const eqSaving     = ref(false)
const eqMsg        = ref('')
const eqError      = ref(false)
const eqForm       = ref({ key: '', is_active: true, activeLang: 'ru', translations: emptyTranslations(), location: '', service_type_id: null })

function openCreateEq() {
  eqForm.value = { key: '', is_active: true, activeLang: 'ru', translations: emptyTranslations(), location: '', service_type_id: null }
  eqMsg.value  = ''
  eqError.value = false
  showCreateEq.value = true
}
function openEditEq(eq) {
  eqEditTarget.value = eq
  eqForm.value = {
    key:            eq.key,
    is_active:      eq.is_active,
    activeLang:     'ru',
    translations:   translationsFromApi(eq.translations),
    location:       eq.location ?? '',
    service_type_id: eq.service_type_id,
  }
  eqMsg.value   = ''
  eqError.value = false
  showEditEq.value = true
}
async function submitCreateEq() {
  eqSaving.value = true
  eqMsg.value    = ''
  eqError.value  = false
  try {
    const payload = {
      key:            eqForm.value.key,
      translations:   buildTranslationPayload(eqForm.value.translations, ['name', 'type_name']),
      location:       eqForm.value.location || null,
      service_type_id: eqForm.value.service_type_id,
    }
    const { data } = await createEquipment(payload)
    equipment.value.push(data)
    showCreateEq.value = false
  } catch (e) {
    eqMsg.value   = e.response?.data?.detail ?? 'Ошибка'
    eqError.value = true
  } finally {
    eqSaving.value = false
  }
}
async function submitEditEq() {
  if (!eqEditTarget.value) return
  eqSaving.value = true
  eqMsg.value    = ''
  eqError.value  = false
  try {
    const payload = {
      key:            eqForm.value.key,
      is_active:      eqForm.value.is_active,
      translations:   buildTranslationPayload(eqForm.value.translations, ['name', 'type_name']),
      location:       eqForm.value.location || null,
      service_type_id: eqForm.value.service_type_id,
    }
    const { data } = await updateEquipment(eqEditTarget.value.id, payload)
    const idx = equipment.value.findIndex((e) => e.id === data.id)
    if (idx !== -1) equipment.value[idx] = data
    showEditEq.value = false
  } catch (e) {
    eqMsg.value   = e.response?.data?.detail ?? 'Ошибка'
    eqError.value = true
  } finally {
    eqSaving.value = false
  }
}
async function deleteEqFn(eq) {
  if (!confirm(t('directories.confirmDelete'))) return
  try {
    await deleteEquipment(eq.id)
    equipment.value = equipment.value.filter((e) => e.id !== eq.id)
  } catch (e) {
    alert(e.response?.data?.detail ?? 'Ошибка')
  }
}

// ── SLA Rule state ────────────────────────────────────────────────────────────

const showCreateSLA = ref(false)
const showEditSLA   = ref(false)
const slaEditTarget = ref(null)
const slaSaving     = ref(false)
const slaMsg        = ref('')
const slaError      = ref(false)
const slaForm       = ref({ service_type_id: null, priority: 3, reaction_minutes: 60, completion_minutes: 480 })

function openCreateSLA() {
  slaForm.value = { service_type_id: null, priority: 3, reaction_minutes: 60, completion_minutes: 480 }
  slaMsg.value  = ''
  slaError.value = false
  showCreateSLA.value = true
}
function openEditSLA(rule) {
  slaEditTarget.value = rule
  slaForm.value = { reaction_minutes: rule.reaction_minutes, completion_minutes: rule.completion_minutes }
  slaMsg.value  = ''
  slaError.value = false
  showEditSLA.value = true
}
async function submitCreateSLA() {
  slaSaving.value = true
  slaMsg.value    = ''
  slaError.value  = false
  try {
    const { data } = await createSlaRule(slaForm.value)
    slaRules.value.push(data)
    showCreateSLA.value = false
  } catch (e) {
    slaMsg.value   = e.response?.data?.detail ?? 'Ошибка'
    slaError.value = true
  } finally {
    slaSaving.value = false
  }
}
async function submitEditSLA() {
  if (!slaEditTarget.value) return
  slaSaving.value = true
  slaMsg.value    = ''
  slaError.value  = false
  try {
    const { data } = await updateSlaRule(slaEditTarget.value.id, {
      reaction_minutes:   slaForm.value.reaction_minutes,
      completion_minutes: slaForm.value.completion_minutes,
    })
    const idx = slaRules.value.findIndex((r) => r.id === data.id)
    if (idx !== -1) slaRules.value[idx] = data
    showEditSLA.value = false
  } catch (e) {
    slaMsg.value   = e.response?.data?.detail ?? 'Ошибка'
    slaError.value = true
  } finally {
    slaSaving.value = false
  }
}
async function deleteSLAFn(rule) {
  if (!confirm(t('directories.confirmDelete'))) return
  try {
    await deleteSlaRule(rule.id)
    slaRules.value = slaRules.value.filter((r) => r.id !== rule.id)
  } catch (e) {
    alert(e.response?.data?.detail ?? 'Ошибка')
  }
}

// ── Load data ─────────────────────────────────────────────────────────────────

onMounted(async () => {
  try {
    const [stRes, eqRes, slaRes] = await Promise.all([
      getServiceTypes(locale.value),
      getEquipment(locale.value),
      getSlaRules(),
    ])
    serviceTypes.value = stRes.data
    equipment.value    = eqRes.data
    slaRules.value     = slaRes.data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})
</script>
