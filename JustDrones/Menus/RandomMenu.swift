//
//  RandomMenu.swift
//  JustDrones
//
//  Created by Eli Pouliot on 6/4/25.
//

import SwiftUI

struct RandomMenu: View {
    @Binding var isRandomMenuOn: Bool
    let namingMode: NamingMode
    
    @State private var noteindex = 0
    @State private var note = String(localized: "Go") /// make this localizable
    private let noteindices = [-9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5]
    
    var body: some View {
        VStack {
            Text("A random note:")
                .padding()
            Button(action: {
                noteindex = noteindices.randomElement()!
                note = NamingHelper.noteName(namingIndex: NamingHelper.namingIndex(fifths: noteindex, thirds: 0), namingMode: namingMode)
            }, label: {
                Circle()
                    .fill(.gray)
                    .frame(width: 54.0)
                    .overlay(
                        HStack(spacing: 1) {
                            ForEach(Array(note.enumerated()), id: \.offset) { index,character in
                                if character.unicodeScalars.allSatisfy({ $0.isASCII }) {
                                    Text(String(character))
                                        .font(.system(size: 17))
                                        .foregroundColor(.black)
                                } else {
                                    Text(String(character))
                                        .font(.custom("Bravura-Text", size: 25))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    )
            })
            
            Button(action: {
                isRandomMenuOn.toggle()
            }) {
                Text("Close")
                    .foregroundStyle(.blue)
            }
            .padding()
        }
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
}
