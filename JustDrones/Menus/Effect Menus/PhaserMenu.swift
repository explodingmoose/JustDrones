//
//  PhaserMenu.swift
//  JustDrones
//
//  Created by Eli Pouliot on 5/30/25.
//

import SwiftUI
import Controls

struct PhaserMenu: View {
    @Binding var isPhaserMenuOpen: Bool
    @Bindable var synth: SynthManager
    
    var body: some View {
        VStack{
            BypassButton(effect: $synth.isPhaser, label: "Phaser")
            Divider()
            HStack{
                VStack{
                    VStack{
                        Text("Floor: \(String(format: "%.2f", synth.notchFloor))Hz")
                        Slider(value: $synth.notchFloor, in: 20...5000)
                    }
                    VStack{
                        Text("Ceiling: \(String(format: "%.2f", synth.notchCeiling))Hz")
                        Slider(value: $synth.notchCeiling, in: synth.notchFloor...10000)
                    }
                    VStack{
                        Text("Frequency: \(String(format: "%.2f", synth.notchFrequency))Hz")
                        Slider(value: $synth.notchFrequency, in: 1.1...4.0)
                    }
                }
                VStack{
                    VStack{
                        Text("LFO Rate: \(String(format: "%.2f", synth.lfoBPM))BPM")
                        Slider(value: $synth.lfoBPM, in: 24...360)
                    }
                    HStack {
                        ArcKnob("DPTH", value: $synth.phaserDepth, range: 0...100)
                        ArcKnob("FDBK", value: $synth.phaserFeedback, range: 0...100)
                    }
                }
            }
            Button(action: {
                isPhaserMenuOpen.toggle()
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
