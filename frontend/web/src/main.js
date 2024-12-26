// Basic
import { createApp } from 'vue'

// App
import App from './App.vue'

// Local storage
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

// Rest API
import axios from './plugins/axios'
import VueAxios from 'vue-axios'

// Navigation
import router from '@/plugins/router'

// Design
import vuetify from '@/plugins/vuetify'
import { loadFonts } from '@/plugins/webfontloader'

loadFonts().then(() => { console.log("Fonts loaded") })

// Create app
createApp(App)
    .use(pinia)
    .use(VueAxios, axios)
    .use(router)
    .use(vuetify)
    .mount('#app')
