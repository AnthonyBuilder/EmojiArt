//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Anthony on 14/05/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: EmojiArtDocument())
        }
    }
}
