// Axios
import axios from 'axios'
import router from "@/plugins/router"
import { useUserStore } from '@/plugins/store'

// Configuration
axios.defaults.baseURL = 'API_BASE_URL'
console.log(`Using API URL: ${axios.defaults.baseURL}`)

// Update login secret when user is set

// Logout if login secret is revoked
axios.interceptors.response.use(undefined, (error) => {
    if (error) {
        const originalRequest = error.config;
        if (error?.response?.status === 401 && !originalRequest._retry) {
            originalRequest._retry = true;

            let store = useUserStore()
            store.logout()
            return router.push("/")
        }
        throw error // rethrow
    }
})

export default axios
