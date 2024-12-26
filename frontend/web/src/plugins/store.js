import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
    state: () => {
        return {
            user: null,
            bandId: null,
            darkMode: false,
            bottomHidden: false,
            shownSbs: {},
            songSizes: {},
            capos: {},
        }
    },
    getters: {
        isLoggedIn: (state) => state.user != null,
    },
    actions: {
        setUser(user) {
            this.user = user
        },
        toggleDarkMode() {
            this.darkMode = !this.darkMode
        },
        logout() {
            this.setUser(null)
        }
    },
    persist: true
})
