import api from './index'

export const getNotifications = (unread_only = false) =>
  api.get('/notifications/', { params: { unread_only } })

export const markAllRead = () => api.post('/notifications/mark-read')
