import api from './index'

export const getTasks = (params = {}) => api.get('/tasks/', { params })

export const getTask = (id) => api.get(`/tasks/${id}`)

export const updateTask = (id, data) => api.patch(`/tasks/${id}`, data)

export const assignTask = (id, worker_id) =>
  api.post(`/tasks/${id}/assign`, { worker_id })

export const createTaskReview = (id, decision, comment = null) =>
  api.post(`/tasks/${id}/review`, { decision, comment })

export const uploadTaskFile = (id, file) => {
  const form = new FormData()
  form.append('file', file)
  return api.post(`/tasks/${id}/files`, form)
}

export const autoAssign = (task_ids) =>
  api.post('/tasks/auto-assign', { task_ids })

export const createTask = (data) => api.post('/tasks/', data)
