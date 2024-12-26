//
//  SongEditDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 30.03.2022.
//

import Foundation

struct SongEditDTO: Codable, Equatable {
    let name: String
    let songBookId: Int
    let key: SongKey
    let bpm: Int
    let beat: SongBeat
    let capo: Int
    let text: String
    let displayId: Int?
}

struct SongNoteEditDTO: Codable, Equatable {
    let notes: String
    let capo: Int
}

// MARK: - Offline editing

struct SongCacheDTO: Codable, Equatable {
    let song: SongEditDTO
    let note: SongNoteEditDTO?
    let operation: SongEditOperation
    let id: Int
}

enum SongEditOperation: Codable, Equatable {
    case create
    case edit
}

extension SongCacheDTO {
    func songDTO(songBook: SongBookRawDTO) -> SongDTO {
        .init(
            id: id,
            songBook: songBook,
            name: song.name,
            text: song.text.songLines,
            key: song.key,
            bpm: song.bpm,
            beat: song.beat,
            capo: song.capo,
            lastEdit: "",
            displayId: song.displayId,
            note: note?.notes.noteLines
        )
    }
}

extension String {
    var songLines: [SongLineDTO] {
        let textLines = components(separatedBy: "\n")
        return textLines.enumerated().compactMap { (index, rawLine) -> SongLineDTO? in
            let line = rawLine.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression) // remove trailing whitespace
            let randomId = String(Int.random(in: 0...Int.max))
            switch line.first {
            case " ":
                let chords: String?
                if let chordLine = index > 0 ? textLines[index - 1] : nil {
                    chords = chordLine.first == "." ? String(chordLine.dropFirst()) : nil
                }
                else {
                    chords = nil
                }
                
                return SongLineDTO(
                    id: randomId,
                    chords: chords,
                    text: String(line.dropFirst())
                )
            case ".":
                return nil // already parsed with text
            default:
                return SongLineDTO(id: randomId, chords: nil, text: line)
            }
        }
    }
    
    var noteLines: SongNoteDTO {
        .init(
            id: Int.random(in: 0...Int.max),
            notes: self,
            capo: 0,
            lastEdit: ""
        )
    }
}
