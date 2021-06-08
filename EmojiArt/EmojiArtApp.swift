//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Anthony on 14/05/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    
    let store = EmojiArtDocumentStore(named: "EmojiArt Store")
    
    func setStoreDocument() {
        store.addDocument(named: "Hello World")
    }

    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentChooser().environmentObject(store).onAppear {
                if store.documents.count == 0 {
                    setStoreDocument()
                }
            }
        }
    }
}
