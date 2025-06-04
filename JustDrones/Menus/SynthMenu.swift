//
//  SynthMenu.swift
//  JustDrones
//
//  Created by Eli Pouliot on 6/4/25.
//

import SwiftUI
import AudioKit
import AudioKitUI
import Controls

struct SynthMenu: View {
    @Bindable var synth: SynthManager
    @Binding var isSynthMenuOpen: Bool
    
    @State private var isSubOscMenuOpen: Bool = false
    @State private var isFilterMenuOpen: Bool = false
    @State private var isLFOMenuOpen: Bool = false
    @State private var isPhaserMenuOpen: Bool = false
    
    var O1Controls: some View {
        VStack {
            Text("Osc 1:")
            HStack {
                Image("Sine")
                    .iconStyle()
                    .onTapGesture{O1Sine()}
                Image("Triangle")
                    .iconStyle()
                    .onTapGesture{O1Triangle()}
                Image("Square")
                    .iconStyle()
                    .onTapGesture{O1Square()}
                Image("Sawtooth")
                    .iconStyle()
                    .onTapGesture{O1Saw()}
            }
            SmallKnob(value: $synth.O1Morph, range: 0...3)
            Text("Morph: \(String(format: "%.2f", synth.O1Morph/3))")
        }
    }
    var O2Controls: some View {
        VStack {
            Text("Osc 2:")
            HStack {
                Image("Sine")
                    .iconStyle()
                    .onTapGesture{O2Sine()}
                Image("Triangle")
                    .iconStyle()
                    .onTapGesture{O2Triangle()}
                Image("Square")
                    .iconStyle()
                    .onTapGesture{O2Square()}
                Image("Sawtooth")
                    .iconStyle()
                    .onTapGesture{O2Saw()}
            }
            .foregroundStyle(.accent)
            SmallKnob(value: $synth.O2Morph, range: 0...3)
            Text("Morph: \(String(format: "%.2f", synth.O2Morph/3))")
        }
    }
    var waveGraph: some View {
        RawOutputView(synth.voiceMixer, strokeColor: .accent, scaleFactor: 0.5)
            .border(.accent, width: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
    var effectMenus: some View {
        VStack {
            Button(action: {isSubOscMenuOpen.toggle()}) {Text("Sub Oscillator")}
            Button(action: {isLFOMenuOpen.toggle()}) {Text("LFO")}
            Button(action: {isFilterMenuOpen.toggle()}) {Text("Filter")}
            Button(action: {isPhaserMenuOpen.toggle()}) {Text("Phaser")}
        }
    }
    
    var subMenu: some View {
        SubOscMenu(isSubOscMenuOpen: $isSubOscMenuOpen, synth: synth)
    }
    var filterMenu: some View {
        FilterMenu(isFilterMenuOpen: $isFilterMenuOpen, synth: synth)
    }
    var lfoMenu: some View {
        LFOMenu(isLFOMenuOpen: $isLFOMenuOpen, synth: synth)
    }
    var phaserMenu: some View {
        PhaserMenu(isPhaserMenuOpen: $isPhaserMenuOpen, synth: synth)
    }
    
    private func O1Sine() {
        synth.O1Morph = 0
    }
    private func O1Triangle() {
        synth.O1Morph = 1
    }
    private func O1Square() {
        synth.O1Morph = 2
    }
    private func O1Saw() {
        synth.O1Morph = 3
    }
    private func O2Sine() {
        synth.O2Morph = 0
    }
    private func O2Triangle() {
        synth.O2Morph = 1
    }
    private func O2Square() {
        synth.O2Morph = 2
    }
    private func O2Saw() {
        synth.O2Morph = 3
    }

    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 50) {
                    O1Controls
                    VStack{
                        Text("Oscillator Balance: \(String(format: "%.2f", synth.shapeBalance))")
                        Slider(value: $synth.shapeBalance, in: 0...1, step: 0.01)
                        
                    }
                    O2Controls
                }
                
                Divider()
                //Master knob
                HStack {
                    VStack {
                        Text("Master Gain: \(String(format: "%.2f", synth.compressorGain)) dB")
                        Slider(value: $synth.compressorGain, in: -12...6)
                        waveGraph
                    }
                    Divider ()
                    effectMenus
                }
                //Close menu button
                Button(action: {isSynthMenuOpen.toggle()}) {Text("Close")
                        .foregroundStyle(.blue)
                }
                .padding(5)
            }
            .padding()
            .background()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 4)
            
            .padding()
                if isSubOscMenuOpen {subMenu}
                if isFilterMenuOpen {filterMenu}
                if isLFOMenuOpen {lfoMenu}
                if isPhaserMenuOpen {phaserMenu}
        }
    }
}
