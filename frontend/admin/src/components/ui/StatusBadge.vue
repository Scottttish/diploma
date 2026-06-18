<template>
  <span class="inline-flex items-center gap-1.5 text-xs font-medium">
    <span class="w-2 h-2 rounded-full shrink-0" :class="dotClass" />
    <span>{{ label }}</span>
  </span>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { STATUS_DOT_CLASSES } from '@/utils/formatters'

const props = defineProps({
  status: {
    type: String,
    required: true,
  },
})

const { t } = useI18n()

const dotClass = computed(() => STATUS_DOT_CLASSES[props.status] ?? 'bg-gray-400')
const label = computed(() => {
  const key = `status.${props.status}`
  const translated = t(key)
  return translated !== key ? translated : props.status
})
</script>
