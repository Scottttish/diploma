<template>
  <div :class="{ dark: uiStore.darkMode }">
    <RouterView />
  </div>
</template>

<script setup>
import { useUIStore } from '@/stores/ui'

const uiStore = useUIStore()
</script>
