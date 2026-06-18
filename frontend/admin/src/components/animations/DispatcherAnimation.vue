<template>
  <div class="flex items-center justify-center">
    <LottiePlayer
      v-if="animData"
      :animation-data="animData"
      :width="width"
      :height="height"
    />
    <div
      v-else
      class="flex flex-col items-center justify-center gap-2 rounded-xl bg-primary/5 dark:bg-white/5 border border-primary/10"
      :style="{ width: width + 'px', height: height + 'px' }"
    >
      <div class="flex gap-3 text-3xl opacity-60">
        <span>🚗</span>
        <span>🔧</span>
      </div>
      <p class="text-xs text-gray-400 dark:text-gray-500 font-medium tracking-wide uppercase">
        Animation
      </p>
      <p class="text-xs text-gray-300 dark:text-gray-600 text-center px-4 leading-tight">
        Place Lottie JSON at<br/>
        <code class="text-primary/60">assets/animations/dispatcher.json</code>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import LottiePlayer from './LottiePlayer.vue'

defineProps({
  width: {
    type: Number,
    default: 220,
  },
  height: {
    type: Number,
    default: 160,
  },
})

const animData = ref(null)

import('@/assets/animations/dispatcher.json')
  .then((m) => {
    animData.value = m.default
  })
  .catch(() => {})
</script>
