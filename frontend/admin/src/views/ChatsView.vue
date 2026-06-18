<template>
  <div class="flex h-full overflow-hidden">
    <!-- Worker list -->
    <aside class="w-72 shrink-0 border-r border-gray-200 dark:border-gray-700 flex flex-col bg-white dark:bg-gray-900">
      <div class="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
        <h2 class="text-sm font-semibold text-gray-700 dark:text-gray-200">{{ $t('nav.workers') }}</h2>
      </div>
      <div v-if="loadingWorkers" class="flex-1 flex items-center justify-center">
        <LoadingSpinner size="md" />
      </div>
      <div v-else-if="workers.length === 0" class="flex-1 flex items-center justify-center">
        <p class="text-sm text-gray-400">{{ $t('chat.noWorkers') }}</p>
      </div>
      <ul v-else class="flex-1 overflow-y-auto divide-y divide-gray-100 dark:divide-gray-800">
        <li
          v-for="worker in workers"
          :key="worker.id"
          class="flex items-center gap-3 px-4 py-3 cursor-pointer transition-colors hover:bg-gray-50 dark:hover:bg-gray-800"
          :class="selectedWorker?.id === worker.id ? 'bg-blue-50 dark:bg-blue-900/20 border-l-2 border-primary' : ''"
          @click="selectWorker(worker)"
        >
          <div class="w-9 h-9 rounded-full bg-primary/10 text-primary flex items-center justify-center text-xs font-semibold shrink-0">
            {{ getInitials(worker.full_name) }}
          </div>
          <div class="min-w-0">
            <p class="text-sm font-medium text-gray-800 dark:text-gray-100 truncate">{{ worker.full_name }}</p>
            <p class="text-xs text-gray-400 truncate">{{ worker.email }}</p>
          </div>
        </li>
      </ul>
    </aside>

    <!-- Chat thread -->
    <div class="flex-1 flex flex-col min-w-0 bg-gray-50 dark:bg-gray-950">
      <!-- Empty state -->
      <div v-if="!selectedWorker" class="flex-1 flex items-center justify-center">
        <div class="text-center">
          <ChatBubbleLeftRightIcon class="w-12 h-12 text-gray-300 dark:text-gray-700 mx-auto mb-3" />
          <p class="text-sm text-gray-400">{{ $t('chat.selectWorker') }}</p>
        </div>
      </div>

      <template v-else>
        <!-- Thread header -->
        <div class="flex items-center gap-3 px-5 py-3 border-b border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 shrink-0">
          <div class="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center text-xs font-semibold">
            {{ getInitials(selectedWorker.full_name) }}
          </div>
          <div>
            <p class="text-sm font-semibold text-gray-800 dark:text-gray-100">{{ selectedWorker.full_name }}</p>
            <p class="text-xs text-gray-400">{{ selectedWorker.email }}</p>
          </div>
        </div>

        <!-- Messages -->
        <div ref="messageContainer" class="flex-1 overflow-y-auto px-5 py-4 space-y-2">
          <div v-if="loadingMessages" class="flex justify-center pt-8">
            <LoadingSpinner size="md" />
          </div>
          <template v-else>
            <div
              v-for="msg in messages"
              :key="msg.id"
              class="flex"
              :class="msg.sender_type === 'dispatcher' ? 'justify-end' : 'justify-start'"
            >
              <div
                class="max-w-[70%] rounded-2xl px-4 py-2 text-sm"
                :class="msg.sender_type === 'dispatcher'
                  ? 'bg-primary text-white rounded-br-sm'
                  : 'bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 shadow-sm rounded-bl-sm'"
              >
                <p class="leading-relaxed break-words">{{ msg.message_text }}</p>
                <p
                  class="text-[10px] mt-1 text-right"
                  :class="msg.sender_type === 'dispatcher' ? 'text-white/60' : 'text-gray-400'"
                >
                  {{ formatTime(msg.sent_at) }}
                </p>
              </div>
            </div>
            <div v-if="messages.length === 0" class="flex justify-center pt-8">
              <p class="text-sm text-gray-400">{{ $t('chat.empty') }}</p>
            </div>
          </template>
        </div>

        <!-- Input bar -->
        <div class="shrink-0 px-5 py-3 border-t border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900">
          <div class="flex items-end gap-3">
            <textarea
              v-model="inputText"
              rows="1"
              class="flex-1 resize-none rounded-xl border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 text-sm text-gray-800 dark:text-gray-100 px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-colors"
              :placeholder="$t('chat.inputPlaceholder')"
              @keydown.enter.exact.prevent="onSend"
            />
            <button
              class="shrink-0 w-10 h-10 rounded-xl bg-primary text-white flex items-center justify-center hover:bg-primary/90 transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
              :disabled="sending || !inputText.trim()"
              @click="onSend"
            >
              <PaperAirplaneIcon v-if="!sending" class="w-4 h-4" />
              <span v-else class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            </button>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, onUnmounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { ChatBubbleLeftRightIcon, PaperAirplaneIcon } from '@heroicons/vue/24/outline'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import { getUsers } from '@/api/users'
import { getWorkerConversation, getMessages, sendMessage } from '@/api/conversations'
import { getInitials } from '@/utils/formatters'

const { t } = useI18n()

const workers = ref([])
const loadingWorkers = ref(true)
const selectedWorker = ref(null)
const conversationId = ref(null)
const messages = ref([])
const loadingMessages = ref(false)
const inputText = ref('')
const sending = ref(false)
const messageContainer = ref(null)

let pollInterval = null

function formatTime(dateStr) {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' })
}

async function loadWorkers() {
  try {
    const { data } = await getUsers({ role: 'worker' })
    workers.value = Array.isArray(data) ? data : (data.items ?? [])
  } catch {
    workers.value = []
  } finally {
    loadingWorkers.value = false
  }
}

async function loadMessages() {
  if (!conversationId.value) return
  try {
    const { data } = await getMessages(conversationId.value)
    messages.value = data
    await scrollToBottom()
  } catch {
    // silent - don't disrupt the UI on poll failures
  }
}

async function selectWorker(worker) {
  if (selectedWorker.value?.id === worker.id) return
  selectedWorker.value = worker
  conversationId.value = null
  messages.value = []
  stopPolling()

  loadingMessages.value = true
  try {
    const { data: conv } = await getWorkerConversation(worker.id)
    conversationId.value = conv.id
    await loadMessages()
    startPolling()
  } catch {
    loadingMessages.value = false
  } finally {
    loadingMessages.value = false
  }
}

async function onSend() {
  const text = inputText.value.trim()
  if (!text || sending.value || !conversationId.value) return
  sending.value = true
  inputText.value = ''
  try {
    const { data: msg } = await sendMessage(conversationId.value, text)
    messages.value.push(msg)
    await scrollToBottom()
  } catch {
    inputText.value = text
  } finally {
    sending.value = false
  }
}

async function scrollToBottom() {
  await nextTick()
  if (messageContainer.value) {
    messageContainer.value.scrollTop = messageContainer.value.scrollHeight
  }
}

function startPolling() {
  stopPolling()
  pollInterval = setInterval(loadMessages, 15000)
}

function stopPolling() {
  if (pollInterval) {
    clearInterval(pollInterval)
    pollInterval = null
  }
}

onUnmounted(stopPolling)

loadWorkers()
</script>
