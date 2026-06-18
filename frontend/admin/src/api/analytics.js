import api from './index'

export const getOverview = () => api.get('/analytics/overview')

export const getWorkerStats = () => api.get('/analytics/workers')

export const getServiceTypeStats = () => api.get('/analytics/service-types')
