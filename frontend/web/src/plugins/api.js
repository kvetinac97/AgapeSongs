import axios from "axios"

const apiClient = {
    async songBookList() {
        const response = await axios.get('/songbook')
        return response.data
    },
    async fetchPlaylist(bandId) {
        const response = await axios.get(`/band/${bandId}/playlist`)
        return response.data
    }
}

export default apiClient
