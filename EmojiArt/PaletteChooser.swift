//
//  PalleteChoser.swift
//  EmojiArt
//
//  Created by Anthony on 28/05/21.
//

import SwiftUI

struct PaletteChooser: View {
    
    @ObservedObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    
    var body: some View {
        HStack {
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { EmptyView() })
            Text(document.paletteNames[self.chosenPalette] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
        .onAppear {
            self.chosenPalette = document.defaultPalette
        }
    }
}

struct PalleteChoser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), chosenPalette: Binding.constant(""))
    }
}
