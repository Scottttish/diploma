import api from './index'

export const getClients = (params = {}) => api.get('/clients/', { params })
