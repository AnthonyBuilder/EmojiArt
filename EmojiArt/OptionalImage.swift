//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Anthony on 20/05/21.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
