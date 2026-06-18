import api from './index'

// Service Types
export const getServiceTypes = (lang = null) =>
  api.get('/directories/service-types', { params: lang ? { lang } : {} })
export const createServiceType = (data) => api.post('/directories/service-types', data)
export const updateServiceType = (id, data) => api.patch(`/directories/service-types/${id}`, data)
export const deleteServiceType = (id) => api.delete(`/directories/service-types/${id}`)

// Equipment
export const getEquipment = (lang = null) =>
  api.get('/directories/equipment', { params: lang ? { lang } : {} })
export const createEquipment = (data) => api.post('/directories/equipment', data)
export const updateEquipment = (id, data) => api.patch(`/directories/equipment/${id}`, data)
export const deleteEquipment = (id) => api.delete(`/directories/equipment/${id}`)

// SLA Rules
export const getSlaRules = () => api.get('/directories/sla-rules')
export const createSlaRule = (data) => api.post('/directories/sla-rules', data)
export const updateSlaRule = (id, data) => api.patch(`/directories/sla-rules/${id}`, data)
export const deleteSlaRule = (id) => api.delete(`/directories/sla-rules/${id}`)

// Worker Skills
export const getWorkerSkills = () => api.get('/directories/worker-skills')
export const createWorkerSkill = (data) => api.post('/directories/worker-skills', data)
export const deleteWorkerSkill = (id) => api.delete(`/directories/worker-skills/${id}`)
