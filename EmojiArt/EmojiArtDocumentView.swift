//
//  ContentView.swift
//  EmojiArt
//
//  Created by Anthony on 14/05/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    @State private var chosenPalette: String = ""
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: defaultEmojiSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        } 
                    }
                }
                .onAppear { self.chosenPalette = document.defaultPalette }
//              Button(action: { document.clearData() }, label: { Text("Limpar") })
            }.padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(self.panOffset)
                    ).gesture(doubleTapToZoom(in: geometry.size))
                    
                    if isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * zoomScale)
                                .position(position(for: emoji, in: geometry.size))
                        }
                    }
                }
                .gesture(zoomGesture())
                .gesture(panGesture())
                .clipped()
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(document.$backgroundImage) { image in
                    zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != self.document.backgoundURL {
                        confirmBackgroundPaste = true
                    } else  {
                        explaingBackgroundPaste = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                        .alert(isPresented: $explaingBackgroundPaste) {
                            Alert(
                                title: Text("Colar Fundo"),
                                message: Text("Esta URL da imagem que esta na área de transferência ja está como plano de fundo do seu documento."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                }))
            }.zIndex(-1)
        }
        .alert(isPresented: $confirmBackgroundPaste) {
            Alert(
                title: Text("Colar Fundo"),
                message: Text("Definir seu plano de fundo com \(UIPasteboard.general.url?.absoluteString ?? "nothing")?."),
                primaryButton: .default(Text("OK")) {
                    document.backgoundURL = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    @State private var explaingBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    var isLoading: Bool {
        document.backgoundURL != nil && document.backgroundImage == nil
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                steadyStateZoomScale *= finalGestureScale
            }
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero

    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation {
                zoomToFit(self.document.backgroundImage, in: size)
            }
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.height > 0, image.size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStateZoomScale = min(hZoom, vZoom)
            steadyStatePanOffset = .zero
        }
    }
    
    private func font(for emoji: EmojiArt.Emoji) -> Font {
        Font.system(size: emoji.fontSize * zoomScale )
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location : CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgoundURL = url
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}
