<script setup>
import { useUserStore } from '@/plugins/store'
import { inject, watch } from 'vue'

const appState = inject('appState')
const userStore = useUserStore()

const callback = (state) => { document.title = 'AgapeSongs' + (state.navigation.length > 1 ? ` | ${state.navigation.slice(-1)[0].name}` : '') }

watch(appState, callback, { deep: true })
</script>

<template>
  <v-app-bar color="indigo" prominent>
    <v-btn icon="mdi-timer-outline" @click="$router.push({name: 'songbook-list'})"></v-btn>

    <v-toolbar-title>
      <router-link :to="{name: item.path, params: item.params}" style="text-decoration: none; color: white"
                   v-for="(item, index) in appState.navigation" :key="item.name">
        {{ item.name + (index !== (appState.navigation.length - 1) ? ' > ' : '') }}
      </router-link>
    </v-toolbar-title>

    {{ userStore.user.username }}
    <v-btn variant="text" icon="" @click="userStore.toggleDarkMode()">
      <v-icon :icon="userStore.darkMode ? 'mdi-weather-night' : 'mdi-weather-sunny'" />
      <v-tooltip activator="parent" location="bottom">{{ userStore.darkMode ? 'Tmavý režim' : 'Světlý režim' }}</v-tooltip>
    </v-btn>
    <v-btn variant="text" icon="" @click="userStore.logout()">
      <v-icon icon="mdi-lock" />
      <v-tooltip activator="parent" location="bottom">Odhlásit se</v-tooltip>
    </v-btn>
  </v-app-bar>
</template>

<style scoped>
</style>