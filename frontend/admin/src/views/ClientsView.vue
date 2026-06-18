<template>
  <div>
    <h1 class="page-title">Клиенты</h1>

    <div class="card overflow-hidden">
      <div v-if="loading" class="py-8 flex justify-center">
        <LoadingSpinner />
      </div>

      <table v-else class="w-full">
        <thead class="table-header">
          <tr>
            <th class="table-cell">Имя</th>
            <th class="table-cell w-36">Телефон</th>
            <th class="table-cell w-40">Telegram ID</th>
            <th class="table-cell w-40">Дата регистрации</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="client in clients" :key="client.id" class="table-row">
            <td class="table-cell font-medium text-gray-800 dark:text-gray-200">{{ client.full_name }}</td>
            <td class="table-cell text-sm text-gray-500 dark:text-gray-400">{{ client.phone || '-' }}</td>
            <td class="table-cell text-xs text-gray-400 dark:text-gray-500 font-mono">{{ client.telegram_id }}</td>
            <td class="table-cell text-xs text-gray-400 dark:text-gray-500">{{ formatDate(client.created_at) }}</td>
          </tr>
        </tbody>
      </table>

      <EmptyState v-if="!loading && !clients.length" message="Клиентов пока нет" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import { getClients } from '@/api/clients'
import { formatDate } from '@/utils/formatters'

const clients = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const { data } = await getClients({ limit: 200 })
    clients.value = data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})
</script>
