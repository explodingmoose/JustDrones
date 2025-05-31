//
//  FilterMenu.swift
//  JustDrones
//
//  Created by Eli Pouliot on 5/30/25.
//

import SwiftUI
import Controls

struct FilterMenu: View {
    @Binding var isFilterMenuOpen: Bool
    @Bindable var synth: SynthManager
    
    var body: some View {
        VStack {
            Text("Low Pass Filter (Moog Ladder)")
            Divider()
            HStack {
                VStack {
                    VStack {
                        Text("Cutoff: \(Int(synth.cutoffFrequency * 2000)) Hz")
                        Slider(value: $synth.cutoffFrequency, in: 0...1)
                    }
                    VStack{
                        Text("Resonance: \(String(format: "%.2f", synth.resonance)) dB")
                        Slider(value: $synth.resonance, in: 0...1)
                    }
                    Button(action: {
                        isFilterMenuOpen.toggle()
                    }) {
                        Text("Close")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    
                }
                .padding()
                HStack {
                    XYPad(x: $synth.cutoffFrequency, y: $synth.resonance)
                        .backgroundColor(.primary)
                        .foregroundColor(.accentColor)
                        .indicatorSize(CGSize(width: 10, height: 10))
                        .cornerRadius(10)
                }
                .padding()
                
            }.padding()
        }
        .padding()
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .zIndex(3)
        
        
    }
}
