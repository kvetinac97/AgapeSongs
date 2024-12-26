export class NavigationElement {
    name
    path
    params
    anonymous

    constructor(name, path, params = null, anonymous = false) {
        this.name = name
        this.path = path
        this.params = params
        this.anonymous = anonymous
    }

    routerPath = () => { return {
        name: this.path,
        params: this.params
    } }
}

export class SongBookList extends NavigationElement {
    constructor() {
        super('AgapeSongs', 'songbook-list')
    }
}

export class SongDetail extends NavigationElement {
    constructor(songbookId, song) {
        super(`${song.name} (${song.displayId})`, 'song-detail', {
            songbook: songbookId,
            song: song.id
        })
    }
}
