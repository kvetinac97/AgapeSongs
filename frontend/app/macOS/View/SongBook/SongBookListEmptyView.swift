//
//  SongBookListEmptyView.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 12.03.2022.
//

import SwiftUI

struct SongBookListEmptyView: View {
    
    @EnvironmentObject var appState: AppState
    
    // MARK: - View
    
    var body: some View {
        HStack {
            Text("songbook_empty")
                .font(.system(size: appState.defaultFontSize))
                .italic()
                .padding([.leading, .trailing], 8)
                .padding([.top, .bottom], 5)
            Spacer()
        }
    }
}
