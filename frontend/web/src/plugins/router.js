import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'songbook-list',
    component: () => import('../views/SongBookListView.vue')
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/SongBookListView.vue')
  },
  {
    path: '/:songbook/songs/:song',
    name: 'song-detail',
    component: () => import('../views/SongDetailView.vue')
  },
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
