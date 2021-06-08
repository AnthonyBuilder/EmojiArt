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
    
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack {
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { EmptyView() })
            Text(document.paletteNames[self.chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    showPaletteEditor = true
                }
                .popover(isPresented: $showPaletteEditor) {
                    PaletteEditor(chosenPalette: $chosenPalette, isShowing: $showPaletteEditor)
                        .frame(minWidth: 300, minHeight: 500)
                        .environmentObject(document)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor: View {
    
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Editor de Paleta").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: { isShowing = false }, label: { Text("Concluido") }).padding()
                }
            }
            Divider()
            Form {
                Section {
                    TextField("Nome da paleta", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            document.renamePalette(chosenPalette, to: self.paletteName)
                        }
                    })
                    TextField("Adiconar Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            chosenPalette = document.addEmoji(emojisToAdd, toPalette: chosenPalette)
                            emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remover Emoji")) {
                    Grid(chosenPalette.map { String($0)}, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                            .onTapGesture {
                                self.chosenPalette = document.removeEmoji(emoji, fromPalette: self .chosenPalette)
                            }
                    }.frame(height: self.height)
                }
            }
        }
        .onAppear { self.paletteName = document.paletteNames[self.chosenPalette] ?? "" }
    }
    
    //MARK: - Drawing Constants
    
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6) * 70 + 70
    }
    
    let fontSize: CGFloat = 30
}

struct PalleteChoser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), chosenPalette: Binding.constant(""))
    }
}
