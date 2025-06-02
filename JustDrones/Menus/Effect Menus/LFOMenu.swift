//
//  LFOMenu.swift
//  JustDrones
//
//  Created by Eli Pouliot on 5/30/25.
//

import SwiftUI
import Controls

struct LFOMenu: View {
    @Binding var isLFOMenuOpen: Bool
    @Bindable var synth: SynthManager
    
    var body: some View {
        VStack {
            BypassButton(effect: $synth.isLFO, label: "LFO (Filter Cutoff)")
            Divider()
            HStack{
                VStack{
                    VStack {
                        Text("Rate: \(String(format: "%.2f", synth.lfoFrequency)) Hz")
                        Slider(value: $synth.lfoFrequency, in: 0...20)
                    }
                    VStack {
                        Text("Depth: \(String(format: "%.2f", synth.lfoDepth)) Hz")
                        Slider(value: $synth.lfoDepth, in: 0...2000)
                    }
                }
                VStack {
                    Text("Shape:")
                    HStack {
                        Image("Sine")
                            .iconStyle()
                            .onTapGesture{synth.lfoIndex = 0}
                        Image("Square")
                            .iconStyle()
                            .onTapGesture{synth.lfoIndex = 1}
                        Image("Sawtooth")
                            .iconStyle()
                            .onTapGesture{synth.lfoIndex = 2}
                        Image("Reverse Sawtooth")
                            .iconStyle()
                            .onTapGesture{synth.lfoIndex = 3}
                    }
                    SmallKnob(value: $synth.lfoIndex, range: 0...3)
                        .frame(width: 50, height: 50)
                    Text("Morph: \(String(format: "%.2f", synth.lfoIndex/3))")
                }
            }
            Button(action: {
                isLFOMenuOpen.toggle()
            }) {
                Text("Close")
                    .foregroundColor(.blue)
            }
            .padding()

        }
        .padding()
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .zIndex(3)
    }
}
