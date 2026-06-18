<template>
  <span class="text-xs font-semibold" :class="textClass">{{ label }}</span>
</template>

<script setup>
import { computed } from 'vue'
import { PRIORITY_LABELS, PRIORITY_TEXT_CLASSES } from '@/utils/formatters'

const props = defineProps({
  priority: {
    type: [String, Number],
    required: true,
  },
})

const priorityMap = {
  low: 1,
  normal: 2,
  high: 3
}

const textClass = computed(() => PRIORITY_TEXT_CLASSES[props.priority] ?? 'text-gray-500')

const label = computed(() => {
  if (props.priority === 'normal') return 'Normal'
  if (props.priority === 'high') return 'High'
  return 'Low'
})

</script>
