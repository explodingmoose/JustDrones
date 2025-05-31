//
//  SubOctave.swift
//  JustDrones
//
//  Created by Eli Pouliot on 5/30/25.
//

import SwiftUI

enum SubOctave: String, CaseIterable {
    case Ottava = "\u{E51C}"
    case Quindicecisma = "\u{E51D}"
}

struct SubOscMenu: View {
    @Binding var isSubOscMenuOpen: Bool
    @ObservedObject var synth: SynthManager
    
    var body: some View {
        VStack{
            HStack {
                Text("Sub Oscillator")
                Button(action: {synth.isSub.toggle()}) {
                    Image(systemName: "power")
                        .foregroundStyle(synth.isSub ? Color.accent : Color.gray)
                }
            }
            Divider()
                PickerPlus(SubOctave.allCases, selection: synth.subOctave) { item in
                    Text(item.rawValue)
                        .font(Font.custom("Bravura-Text", size: 24))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .onTapGesture {
                            synth.subOctave = item
                        }
                }
                .padding()
            //TODO: Add controls for subOsc balance
            
            Button(action: {isSubOscMenuOpen.toggle()}) {
                Text("Close")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
}
