export function formatDate(dateStr) {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  return d.toLocaleString('ru-RU', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

export function formatDateShort(dateStr) {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  return d.toLocaleDateString('ru-RU', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  })
}

export function isOverdue(deadlineStr) {
  if (!deadlineStr) return false
  return new Date(deadlineStr) < new Date()
}

export const STATUS_DOT_CLASSES = {
  new: 'bg-status-new',
  assigned: 'bg-status-assigned',
  in_progress: 'bg-status-inprogress',
  completed: 'bg-status-completed',
  approved: 'bg-status-approved',
  rejected: 'bg-status-rejected',
  overdue: 'bg-status-overdue',
}

export const STATUS_TEXT_CLASSES = {
  new: 'text-status-new',
  assigned: 'text-status-assigned',
  in_progress: 'text-status-inprogress',
  completed: 'text-status-completed',
  approved: 'text-status-approved',
  rejected: 'text-status-rejected',
  overdue: 'text-status-overdue',
}

export const STATUS_BORDER_CLASSES = {
  new: 'border-l-status-new',
  assigned: 'border-l-status-assigned',
  in_progress: 'border-l-status-inprogress',
  completed: 'border-l-status-completed',
  approved: 'border-l-status-approved',
  rejected: 'border-l-status-rejected',
  overdue: 'border-l-status-overdue',
}

export const PRIORITY_LABELS = {
  1: 'Критичный',
  2: 'Высокий',
  3: 'Нормальный',
  4: 'Низкий',
}

export const PRIORITY_TEXT_CLASSES = {
  1: 'text-status-overdue',
  2: 'text-status-inprogress',
  3: 'text-status-new',
  4: 'text-gray-400',
}

export function getInitials(name) {
  if (!name) return '?'
  return name
    .split(' ')
    .slice(0, 2)
    .map((w) => w[0])
    .join('')
    .toUpperCase()
}
