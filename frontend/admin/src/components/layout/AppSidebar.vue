<template>
    <aside class="flex flex-col bg-primary text-white transition-all duration-200 shrink-0 h-screen" :class="uiStore.sidebarCollapsed ? 'w-16' : 'w-64'">
    
        <!-- Logo / Brand -->
    
        <div class="flex items-center gap-3 px-4 h-14 border-b border-white/10">
    
            <div class="w-7 h-7 rounded bg-white/20 flex items-center justify-center shrink-0">
    
                <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
    
                d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
    
            </svg>
    
            </div>
    
            <span v-if="!uiStore.sidebarCollapsed" class="font-semibold text-sm tracking-wide truncate">
    
            Диспетчерская
    
          </span>
    
        </div>
    
    
    
        <!-- Toggle button -->
    
        <button class="flex items-center justify-center h-8 mx-2 mt-2 mb-1 rounded hover:bg-white/10 text-white/60 hover:text-white transition-colors" @click="uiStore.toggleSidebar()">
    
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
    
              :d="uiStore.sidebarCollapsed ? 'M13 5l7 7-7 7M5 5l7 7-7 7' : 'M11 19l-7-7 7-7m8 14l-7-7 7-7'" />
    
          </svg>
    
        </button>
    
    
    
        <!-- Navigation -->
    
        <nav class="flex-1 px-2 py-2 space-y-0.5 overflow-y-auto">
    
            <RouterLink v-for="item in navItems" :key="item.path" :to="item.path" class="flex items-center gap-3 px-3 py-2.5 rounded text-sm font-medium transition-colors text-white/70 hover:text-white hover:bg-white/10" active-class="!text-white !bg-white/10 border-l-2 border-white !pl-[10px]"
    
                :exact="item.exact">
    
                <component :is="item.icon" class="w-5 h-5 shrink-0" />
    
                <span v-if="!uiStore.sidebarCollapsed" class="truncate">{{ item.label }}</span>
    
            </RouterLink>
    
        </nav>
    
    
    
        <!-- Footer -->
    
        <div class="px-4 py-3 border-t border-white/10">
    
            <p v-if="!uiStore.sidebarCollapsed" class="text-xs text-white/30">v1.0.0</p>
    
            <div v-else class="w-2 h-2 rounded-full bg-white/20 mx-auto" />
    
        </div>
    
    </aside>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useUIStore } from '@/stores/ui'
import { useAuthStore } from '@/stores/auth'
import {
    Squares2X2Icon,
    ClipboardDocumentListIcon,
    UsersIcon,
    CalendarDaysIcon,
    MapIcon,
    ChartBarIcon,
    BellIcon,
    Cog6ToothIcon,
    UserGroupIcon,
    FolderOpenIcon,
    ChatBubbleLeftRightIcon,
} from '@heroicons/vue/24/outline'

const { t } = useI18n()
const uiStore = useUIStore()
const authStore = useAuthStore()

// Each role sees a curated set of routes — items absent from this map are never rendered in the DOM.
// Using getter functions for labels keeps translations reactive without re-defining the map on each render.
const navByRole = {
    manager: [
        { path: '/analytics',     labelKey: 'nav.analytics',     icon: ChartBarIcon },
        { path: '/workers',       labelKey: 'nav.workers',        icon: UsersIcon },
        { path: '/clients',       labelKey: 'nav.clients',        icon: UserGroupIcon },
        { path: '/notifications', labelKey: 'nav.notifications',  icon: BellIcon },
        { path: '/settings',      labelKey: 'nav.settings',       icon: Cog6ToothIcon },
    ],
    administrator: [
        { path: '/tasks',         labelKey: 'nav.tasks',          icon: ClipboardDocumentListIcon },
        { path: '/directories',   labelKey: 'nav.directories',    icon: FolderOpenIcon },
        { path: '/notifications', labelKey: 'nav.notifications',  icon: BellIcon },
        { path: '/settings',      labelKey: 'nav.settings',       icon: Cog6ToothIcon },
    ],
    dispatcher: [
        { path: '/',              labelKey: 'nav.dashboard',      icon: Squares2X2Icon, exact: true },
        { path: '/tasks',         labelKey: 'nav.tasks',          icon: ClipboardDocumentListIcon },
        { path: '/chats',         labelKey: 'nav.chats',          icon: ChatBubbleLeftRightIcon },
        { path: '/scheduling',    labelKey: 'nav.scheduling',     icon: CalendarDaysIcon },
        { path: '/map',           labelKey: 'nav.map',            icon: MapIcon },
        { path: '/notifications', labelKey: 'nav.notifications',  icon: BellIcon },
        { path: '/settings',      labelKey: 'nav.settings',       icon: Cog6ToothIcon },
    ],
}

const navItems = computed(() =>
    (navByRole[authStore.role] ?? []).map(item => ({ ...item, label: t(item.labelKey) }))
)
</script>
