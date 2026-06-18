import api from './index'

export const getUsers = (params = {}) => api.get('/users/', { params })

export const createUser = (data) => api.post('/users/', data)

export const updateUser = (id, data) => api.patch(`/users/${id}`, data)

export const resetUserPassword = (id, newPassword) =>
  api.patch(`/users/${id}/password`, { new_password: newPassword })

export const changeMyPassword = (currentPassword, newPassword) =>
  api.patch('/users/me/password', { current_password: currentPassword, new_password: newPassword })
