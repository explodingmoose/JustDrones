//
//  SubOctave.swift
//  JustDrones
//
//  Created by Eli Pouliot on 5/30/25.
//

import SwiftUI

enum SubOctave: String, CaseIterable, Codable {
    case Ottava = "8vb"
    case Quindicecisma = "15mb"
}

struct SubOscMenu: View {
    @Binding var isSubOscMenuOpen: Bool
    @Bindable var synth: SynthManager
    
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
            Picker("Sub Octave", selection: $synth.subOctave) {
                Text("8vb").tag(SubOctave.Ottava)
                Text("15mb").tag(SubOctave.Quindicecisma)
            }
                .pickerStyle(.segmented)
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
