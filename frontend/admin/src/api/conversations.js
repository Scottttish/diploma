import api from './index'

export const getWorkerConversation = (workerId) =>
  api.get(`/conversations/worker/${workerId}`)

export const getMessages = (conversationId) =>
  api.get(`/conversations/${conversationId}/messages`)

export const sendMessage = (conversationId, messageText) =>
  api.post(`/conversations/${conversationId}/messages`, {
    message_text: messageText,
    sender_type: 'dispatcher',
  })
