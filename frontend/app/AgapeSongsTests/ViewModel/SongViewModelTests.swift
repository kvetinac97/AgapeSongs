//
//  SongViewModelTests.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 06.04.2022.
//

import Foundation
import XCTest

@testable import AgapeSongs

final class SongViewModelTests: AgapeSongsTestCase {
    
    private struct DI: HasAppState & HasSongService {
        let appState: AppState
        let songService: SongServicing
    }
    
    private var viewModel: SongViewModel!
    
    override func setUp() {
        super.setUp()
        setUpViewModel()
    }
    
    // MARK: - Tests (divide)
    
    func testDivideNoSplitChordsText() {
        let line = SongLine(
            id: "",
            chords: "C         F           G",
            text:   "This line will not be trimmed"
        )
        
        let lines = viewModel.divide(line: line, with: 100)
        
        XCTAssertEqual(lines, [line])
    }
    
    func testDivideNoSplitText() {
        let line = SongLine(
            id: "",
            chords: nil,
            text:   "This line will not be trimmed"
        )
        
        let lines = viewModel.divide(line: line, with: 100)
        
        XCTAssertEqual(lines, [line])
    }
    
    func testDivideSplitEasyChordsText() {
        let line = SongLine(
            id: "",
            chords: "C    F    G",
            text:   "Will trim this"
        )
        
        let lines = viewModel.divide(line: line, with: 10)
        
        XCTAssertEqual(lines, [
            SongLine(
                id: "_1",
                chords: "C    F   ",
                text:   "Will trim"
            ),
            SongLine(
                id: "_2",
                chords: "G",
                text:   "this"
            ),
        ])
    }
    
    func testDivideSplitEasyText() {
        let line = SongLine(
            id: "",
            chords: nil,
            text:   "Will trim this"
        )
        
        let lines = viewModel.divide(line: line, with: 10)
        
        XCTAssertEqual(lines, [
            SongLine(
                id: "_1",
                chords: nil,
                text:   "Will trim"
            ),
            SongLine(
                id: "_2",
                chords: nil,
                text:   "this"
            ),
        ])
    }
    
    func testDivideSplitHardTextChords() {
        let line = SongLine(
            id: "",
            chords: "C  F G   C  F  G",
            text:   "Hard test easy test"
        )
        
        let lines = viewModel.divide(line: line, with: 8)
        
        XCTAssertEqual(lines, [
            SongLine(
                id: "_1",
                chords: "C  F",
                text:   "Hard"
            ),
            SongLine(
                id: "_2_1",
                chords: "G   C  F",
                text:   "test eas"
            ),
            SongLine(
                id: "_2_2",
                chords: "  G",
                text:   "y test"
            ),
        ])
    }
    
    func testDivideSplitHardText() {
        let line = SongLine(
            id: "",
            chords: nil,
            text:   "Hard testaeasy test"
        )
        
        let lines = viewModel.divide(line: line, with: 8)
        
        XCTAssertEqual(lines, [
            SongLine(
                id: "_1",
                chords: nil,
                text:   "Hard"
            ),
            SongLine(
                id: "_2_1",
                chords: nil,
                text:   "testaeas"
            ),
            SongLine(
                id: "_2_2",
                chords: nil,
                text:   "y test"
            ),
        ])
    }
    
    func testDivideSplitLowMaxChars() {
        let line = SongLine(
            id: "",
            chords: "C    F  G",
            text:   "Low max chars"
        )
        
        let lines = viewModel.divide(line: line, with: 3)
        
        XCTAssertEqual(lines, [line])
    }
    
    // MARK: - Tests (transposeAndHide)
    
    private let dummySong = Song(
        songId: 1,
        songBook: SongBookRaw(id: 1, name: "", band: Band(id: 1, name: "", secret: "", members: [])),
        name: "", text: [], key: SongKey.E, bpm: 120, capo: 0, lastEdit: "2022-01-01 01:00:00",
        displayId: 1, note: nil, inPlaylist: false
    )
    
    func testChordsHidden() {
        let line = SongLine(
            id: "",
            chords: "C  F   G",
            text:   "Random text"
        )
        appState.chordDisplayMode = .hidden
        
        let result = viewModel.transposeAndHide(line: line, song: dummySong)
        
        XCTAssertEqual(result, nil)
    }
    
    func testTransposeEasy() {
        let line = SongLine(
            id: "",
            chords: "C  F   G",
            text:   "Random text"
        )
        viewModel.capo = 2
        
        let result = viewModel.transposeAndHide(line: line, song: dummySong)
        
        XCTAssertEqual(result, "D  G   A")
    }
    
    func testTransposeHardFlat() {
        let line = SongLine(
            id: "",
            chords: "C  F   G Ami Emi C    G",
            text:   "Random text with long line"
        )
        viewModel.capo = 1
        
        let result = viewModel.transposeAndHide(line: line, song: dummySong)
        
        XCTAssertEqual(result, "Db Gb  Ab Bmi Fmi Db  Ab")
    }
    
    func testTransposeAlwaysSharps() {
        let line = SongLine(
            id: "",
            chords: "C  F   G Ami Emi C    G",
            text:   "Random text with long line"
        )
        viewModel.capo = 1
        appState.chordDisplayMode = .sharps
        
        let result = viewModel.transposeAndHide(line: line, song: dummySong)
        
        XCTAssertEqual(result, "C# F#  G# Bmi Fmi C#  G#")
    }
    
    func testTransposeHardSharp() {
        let line = SongLine(
            id: "",
            chords: "C  F   G Ami Emi C    G",
            text:   "Random text with long line"
        )
        viewModel.capo = 1
        let copySong = Song(songId: dummySong.songId, songBook: dummySong.songBook, name: dummySong.name, text: dummySong.text, key: SongKey.C, bpm: dummySong.bpm, capo: 0,  lastEdit: dummySong.lastEdit, displayId: dummySong.displayId, note: dummySong.note, inPlaylist: dummySong.inPlaylist)
        
        let result = viewModel.transposeAndHide(line: line, song: copySong)
        
        XCTAssertEqual(result, "C# F#  G# Bmi Fmi C#  G#")
    }
    
    func testTransposeAlwaysFlats() {
        let line = SongLine(
            id: "",
            chords: "C  F   G Ami Emi C    G",
            text:   "Random text with long line"
        )
        viewModel.capo = 1
        appState.chordDisplayMode = .flats
        let copySong = Song(songId: dummySong.songId, songBook: dummySong.songBook, name: dummySong.name, text: dummySong.text, key: SongKey.C, bpm: dummySong.bpm, capo: 0,  lastEdit: dummySong.lastEdit, displayId: dummySong.displayId, note: dummySong.note, inPlaylist: dummySong.inPlaylist)
        
        let result = viewModel.transposeAndHide(line: line, song: copySong)
        
        XCTAssertEqual(result, "Db Gb  Ab Bmi Fmi Db  Ab")
    }
    
    // MARK: - Private helpers
    
    private func setUpViewModel() {
        viewModel = SongViewModel(
            context: DI(
                appState: appState,
                songService: songService
            )
        )
    }
}
