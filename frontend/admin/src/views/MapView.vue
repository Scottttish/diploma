<template>
  <div>
    <h1 class="page-title">{{ $t('nav.map') }}</h1>

    <div class="card overflow-hidden">
      <!-- Legend -->
      <div class="px-4 py-3 border-b border-gray-100 dark:border-gray-700 flex flex-wrap gap-4">
        <div class="flex items-center gap-1.5 text-sm text-gray-600 dark:text-gray-400">
          <span class="w-3 h-3 rounded-full bg-status-new inline-block" />
          {{ $t('map.newTasks') }}
        </div>
        <div class="flex items-center gap-1.5 text-sm text-gray-600 dark:text-gray-400">
          <span class="w-3 h-3 rounded-full bg-status-inprogress inline-block" />
          {{ $t('map.inProgress') }}
        </div>
        <div class="flex items-center gap-1.5 text-sm text-gray-600 dark:text-gray-400">
          <span class="w-3 h-3 rounded-full bg-status-overdue inline-block" />
          {{ $t('map.overdue') }}
        </div>
        <div class="flex items-center gap-1.5 text-sm text-gray-600 dark:text-gray-400">
          <span class="w-3 h-3 rounded-full bg-status-completed inline-block" />
          {{ $t('map.completed') }}
        </div>
      </div>

      <!-- Map container -->
      <div ref="mapContainer" style="height: 520px; z-index: 0;" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'

import markerIconUrl from 'leaflet/dist/images/marker-icon.png'
import markerIcon2xUrl from 'leaflet/dist/images/marker-icon-2x.png'
import markerShadowUrl from 'leaflet/dist/images/marker-shadow.png'

delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconUrl: markerIconUrl,
  iconRetinaUrl: markerIcon2xUrl,
  shadowUrl: markerShadowUrl,
})

const mapContainer = ref(null)
let map = null

const STATUS_COLORS = {
  new: '#3B82F6',
  assigned: '#8B5CF6',
  in_progress: '#F59E0B',
  completed: '#10B981',
  overdue: '#EF4444',
  rejected: '#6B7280',
}

function makeIcon(color) {
  return L.divIcon({
    html: `<div style="width:12px;height:12px;border-radius:50%;background:${color};border:2px solid white;box-shadow:0 1px 4px rgba(0,0,0,.4);"></div>`,
    className: '',
    iconSize: [12, 12],
    iconAnchor: [6, 6],
  })
}

onMounted(() => {
  map = L.map(mapContainer.value).setView([43.238, 76.945], 12)

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors',
    maxZoom: 18,
  }).addTo(map)

  const placeholders = [
  ]

  for (const p of placeholders) {
    L.marker([p.lat, p.lng], { icon: makeIcon(STATUS_COLORS[p.status]) })
      .addTo(map)
      .bindPopup(`<div style="font-family:Inter,sans-serif;font-size:13px"><strong>${p.title}</strong></div>`)
  }
})

onUnmounted(() => {
  map?.remove()
})
</script>
