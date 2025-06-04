//
//  ContentViewPreview.swift
//  JustDrones
//
//  Created by Eli Pouliot on 5/31/25.
//

import SwiftUI
struct SubOscMenuPreview: View {
    @State var isSubOscMenuOpen: Bool = false
    
    @State var isSub: Bool = true
    @State var subOctave: SubOctave = .Ottava
    
    var body: some View {
        VStack{
            HStack {
                Text("Sub Oscillator")
                Button(action: {isSub.toggle()}) {
                    Image(systemName: "power")
                        .foregroundStyle(isSub ? Color.accent : Color.gray)
                }
            }
            Divider()
            //TODO: Is this Picker with symbol necessary? Could use semitones or Italian name
            Picker("Sub Octave", selection: $subOctave) {
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
