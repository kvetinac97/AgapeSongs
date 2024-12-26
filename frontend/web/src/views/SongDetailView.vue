<script setup>
import SongDetail from '@/components/SongDetail.vue'
</script>

<template>
  <v-main style="background: white; color: black;">
    <SongDetail :song-book-id="$route.params.songbook" :song-id="$route.params.song" />
  </v-main>
</template>
