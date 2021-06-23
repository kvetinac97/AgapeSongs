//
//  PlaylistHolder.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 23.06.2021.
//

import Foundation

final class PlaylistHolder : ObservableObject {
    
    // Current playlists
    @Published var lists = [Playlist]()
    
    // Original lists
    @Published private var originalLists = [Playlist]()
    
    // Function to load songs
    func loadSongs () {
        // Find documents folder
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        
        // Find AgapeSongs folder
        let fileUrl = documentsUrl.appendingPathComponent("AgapeSongs-master")?.appendingPathComponent("Songs")
        
        // Tmp map for playlist loading
        var tmpPlaylistMap = [String: Int]()
        var tmpSongMap = [String: Int]()
        
        var lists = [Playlist(id: "Playlist", songs: [])]
        var listId = 1
        
        // For each directory, create a playlist
        try? FileManager.default.contentsOfDirectory(at: fileUrl!, includingPropertiesForKeys: nil).sorted(by: {($0.pathComponents.last ?? "") < ($1.pathComponents.last ?? "")}).forEach {
            var songs = [Song]()
            
            // For each playlist subdirectory, create a song
            try? FileManager.default.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil).sorted(by: {($0.pathComponents.last ?? "") < ($1.pathComponents.last ?? "")}).forEach {
                // Parse from XML
                var text = try? String(contentsOf: $0, encoding: .utf8).components(separatedBy: "<lyrics>").last?.components(separatedBy: "</lyrics>").first?.components(separatedBy: "\n")
                
                if text == nil {
                    return
                }
                
                if text?.first?.starts(with: "[V1]") == true {
                    text?.removeFirst()
                }
                
                // Put song inside
                songs.append(Song(id: $0.pathComponents.last ?? "", lines: text!, realId: $0.pathComponents.last ?? "", realListId: listId, listId: listId))
            }
            
            if songs.isEmpty {
                return
            }
            
            // Sort alphabetically and reindex
            songs.sort(by: {$0.id < $1.id})
            for i in 0 ... songs.count - 1 {
                songs[i].songId = i
                tmpSongMap[songs[i].id] = i
            }
            
            // Add playlist with songs
            lists.append(Playlist(id: $0.pathComponents.last ?? "", songs: songs))
            tmpPlaylistMap[$0.pathComponents.last ?? ""] = listId
            listId += 1
            
            print("\(songs.count) songs added to playlist \($0.pathComponents.last ?? "")")
        }
        
        // Publish load
        self.lists = lists

        #if os(macOS)
        loadOneList(documentsUrl, &tmpPlaylistMap, &tmpSongMap)
        #else
        self.originalLists = lists
        #endif
        
        // Load saved playlist (if there is any)
        loadPlaylist(documentsUrl, tmpPlaylistMap, tmpSongMap)
    }
    
    #if os(macOS)
    // Optionally, users on macOS can select to have only one folder
    func loadOneList (_ documentsUrl: NSURL, _ tmpPlaylistMap: inout [String: Int], _ tmpSongMap: inout [String: Int]) {
        // One directory setting
        let oneFolderUrl = documentsUrl.appendingPathComponent("AgapeSongs-master")?.appendingPathComponent("OneFolder.txt")
        let ONE_DIR = oneFolderUrl != nil && FileManager.default.fileExists(atPath: oneFolderUrl!.path)
        
        // Move all songs to one big list (if we should)
        if ONE_DIR {
            let originalLists = lists
            lists = [Playlist(id: "Playlist", songs: []), Playlist(id: "Všechno", songs: [])]
            
            for list in originalLists {
                lists[1].songs.append(contentsOf: list.songs)
                tmpPlaylistMap[list.id] = 1
            }
            
            lists[1].songs.sort(by: {$0.id < $1.id})
            
            // Remove duplicates to avoid crash
            let crossReference = Dictionary(grouping: lists[1].songs, by: \.id)
                .filter { $1.count > 1 }
            for (duplicatedId, _) in crossReference {
                lists[1].songs.removeAll(where: { $0.id == duplicatedId })
            }
            
            for i in 0 ... lists[1].songs.count - 1 {
                lists[1].songs[i].songId = i
                lists[1].songs[i].listId = 1 // real id stays right
                tmpSongMap[lists[1].songs[i].id] = i
            }
            
            self.originalLists = originalLists
        }
        else {
            self.originalLists = lists
        }
    }
    #endif
    
    // Function to load playlist
    private func loadPlaylist (_ documentsUrl: NSURL, _ tmpPlaylistMap: [String: Int], _ tmpSongMap: [String: Int]) {
        if let fileUrl = documentsUrl.appendingPathComponent("AgapeSongs-master")?.appendingPathComponent("Sets").appendingPathComponent("Playlist"), let savedXml = try? String(contentsOf: fileUrl, encoding: .utf8) {
            
            var slideGroupParts = savedXml.components(separatedBy: "<slide_group ")
            if slideGroupParts.count > 1 {
                slideGroupParts.removeFirst()
                for slideGroupPart in slideGroupParts {
                    if let songName = slideGroupPart.components(separatedBy: "name=\"").get(1)?.components(separatedBy: "\"").get(0) , let listName = slideGroupPart.components(separatedBy: "path=\"").get(1)?.components(separatedBy: "/\"").get(0), let song = lists.get(tmpPlaylistMap[listName] ?? -1)?.songs.get(tmpSongMap[songName] ?? -1)  {
                        let cpSong = Song(id: "P: " + song.id, lines: song.lines, realId: song.id, realListId: song.listId, listId: 0, songId: lists[0].songs.count)
                        lists[0].songs.append(cpSong)
                    }
                    else {
                        print("Failed parsing \(slideGroupPart)")
                    }
                }
            }
        }
    }
    
    // Function to save playlist
    func savePlaylist () {
        // Find document folder
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        // Find AgapeSongs folder
        if let fileUrl = documentsUrl.appendingPathComponent("AgapeSongs-master")?.appendingPathComponent("Sets").appendingPathComponent("Playlist") {
            
            // Write songs
            var txt = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<set name=\"Playlist\">\n    <slide_groups>\n"
            
            for listSong in lists[0].songs {
                txt += "        <slide_group name=\"\(listSong.realId.replacingOccurrences(of: "\"", with: ""))\" type=\"song\" presentation=\"\" path=\"\(originalLists[listSong.realListId].id.replacingOccurrences(of: "\"", with: ""))/\"/>\n"
            }
            
            txt += "    </slide_groups>\n</set>\n"
            
            try? txt.write(to: fileUrl, atomically: true, encoding: .utf8)
        }
    }
    
}

// Helper extension for array
extension Array {
    func get(_ index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}
