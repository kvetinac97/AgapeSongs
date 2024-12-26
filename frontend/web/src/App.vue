<script setup>
import axios from 'axios'
import { useTheme } from 'vuetify'
import { watch, ref, provide } from 'vue'

import { SongBookList } from '@/plugins/nav'
import { useUserStore } from '@/plugins/store'

import LoginForm from '@/components/LoginForm.vue'
import CustomAppBar from '@/components/CustomAppBar.vue'

const appState = ref({
  navigation: [new SongBookList()]
})

const store = useUserStore()

const theme = useTheme()
axios.defaults.headers.common['LOGIN_SECRET'] = store.user?.loginSecret
theme.global.name.value = store.darkMode ? 'customLight' : 'customDark'
watch(
    store.$state,
    (state) => {
      axios.defaults.headers.common['LOGIN_SECRET'] = state.user?.loginSecret
      theme.global.name.value = store.darkMode ? 'customLight' : 'customDark'
    },
    { deep: true }
)

provide('appState', appState)
</script>

<template>
  <div v-if="store.isLoggedIn">
    <v-app>
      <CustomAppBar />
      <router-view />
    </v-app>
  </div>
  <div v-else>
    <v-app>
      <v-main>
        <LoginForm />
      </v-main>
    </v-app>
  </div>
</template>
