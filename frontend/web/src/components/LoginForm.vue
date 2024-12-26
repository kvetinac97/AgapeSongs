<script setup>
import { useUserStore } from '@/plugins/store'
import router from '@/plugins/router'
import { SongBookList } from '@/plugins/nav'

const login = async () => {
  let store = useUserStore()
  store.setUser({
    id: YOUR_USER_ID,
    bandId: YOUR_BAND_ID,
    username: YOUR_USER_NAME,
    loginSecret: YOUR_USER_SECRET,
  })
  await router.push(new SongBookList().routerPath())
}
</script>

<template>
  <div>
    <v-card class="mx-auto my-12 pa-12 pb-8" elevation="8" max-width="448" rounded="lg">
      <div class="d-flex justify-center align-center">
        <v-icon size="large" icon="mdi-timer-outline" />
        <h1 class="ps-4 text-center">AgapeSongs Web</h1>
      </div>

      <v-btn :block="true" class="mt-8 mb-6" color="blue" size="large" variant="tonal"
        @click="() => login()">Přihlásit</v-btn>
    </v-card>
  </div>
</template>
