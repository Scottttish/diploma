import { defineStore } from 'pinia'
import { getTasks, updateTask, assignTask } from '@/api/tasks'

export const useTasksStore = defineStore('tasks', {
  state: () => ({
    tasks: [],
    loading: false,
    error: null,
    filters: {
      status: null,
    },
    pagination: { skip: 0, limit: 100 },
  }),
  actions: {
    async fetch() {
      this.loading = true
      this.error = null
      try {
        const params = {
          skip: this.pagination.skip,
          limit: this.pagination.limit,
        }
        if (this.filters.status) params.status = this.filters.status
        const { data } = await getTasks(params)
        this.tasks = data
      } catch (e) {
        this.error = e.message
      } finally {
        this.loading = false
      }
    },
    setFilter(status) {
      this.filters.status = status
      this.fetch()
    },
    clearFilter() {
      this.filters.status = null
      this.fetch()
    },
    async update(id, data) {
      const { data: updated } = await updateTask(id, data)
      const idx = this.tasks.findIndex((t) => t.id === id)
      if (idx !== -1) this.tasks[idx] = updated
      return updated
    },
    async assign(id, worker_id) {
      const { data: updated } = await assignTask(id, worker_id)
      const idx = this.tasks.findIndex((t) => t.id === id)
      if (idx !== -1) this.tasks[idx] = updated
      return updated
    },
  },
})
