//
//  Menus.swift
//  JustDrones
//
//  Created by Eli Pouliot on 8/26/23.
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
struct ControlMenu: View {
    private let diapasons = [415, 422, 423, 432, 435, 436, 439, 440, 441, 442, 443, 444, 445, 446]
    private let stops = [2, 4, 8, 16, 32, 64]
    @Bindable var droneManager: DroneManager
    var synth: SynthManager
    
    @Binding var isControlMenuOpen: Bool
    @Binding var displayMode: DisplayMode
    @Binding var tuningMode: TuningMode
    @Binding var namingMode: NamingMode
    
    var body: some View {
        VStack (alignment: .center){
            GeometryReader { geometry in
                let midx = geometry.size.width / 2.0
                let midy = geometry.size.height / 2.0
                VStack {
                    
                        Picker("Tuning Mode", selection: $tuningMode) {
                            Text("Circle of Fifths").tag(TuningMode.CircleFifths)
                            Text("Tonnetz").tag(TuningMode.Tonnetz)
                            Text("Recorded").tag(TuningMode.Recorded)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: tuningMode) {
                            synth.clearQueue()
                        }
                        .padding()
                    
                    
                    VStack {
                        HStack(spacing: 10) {
                            Text("Display Mode:")
                            Picker("Display Mode", selection: $displayMode) {
                                Text("Pitch Class").tag(DisplayMode.pitchClass)
                                Text("Frequency").tag(DisplayMode.frequency)
                                Text("Note Name").tag(DisplayMode.noteName)
                            }
                            .pickerStyle(.menu)
                        }
                        
                        HStack(spacing: 10) {
                            Text("Diapason:")
                            Picker("Standard A4", selection: $droneManager.diapason) {
                                ForEach(diapasons, id: \.self) {
                                    Text("\(String($0)) Hz")
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        HStack(spacing: 10) {
                            Text("Stop:")
                            Picker("Standard A4", selection: $droneManager.stop) {
                                ForEach(stops, id: \.self) {
                                    Text("\(String($0))'")
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        HStack(spacing: 10) {
                            Text("Name Notation:")
                            Picker("Note Name", selection: $namingMode) {
                                ForEach(NamingMode.allCases) { language in
                                    Text(language.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Button(action: {
                            synth.clearQueue()
                        }) {
                            Text("Stop All Drones!")
                                .foregroundStyle(Color.accentColor)
                        }
                        
                    }
                    
                    Button(action: {
                        isControlMenuOpen.toggle()
                    }) {
                        Text("Close")
                            .foregroundStyle(.blue)
                    }
                    .padding()
                }
                .padding(16)
                .position(x: midx, y: midy)
            }
        }
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .shadow(radius: 4)
        .zIndex(2)
    }
}
struct RandomMenu: View {
    @Binding var isRandomMenuOn: Bool
    
    @State private var note = "Go"
    private let notes = ["A", "A\u{266F}/B\u{266D}", "B", "C", "C\u{266F}/D\u{266D}", "D", "D\u{266F}/E\u{266D}", "E", "F", "F\u{266F}/G\u{266D}", "G", "G\u{266F}/A\u{266D}"]
    
    var body: some View {
        VStack {
            Text("A random note:")
                .padding()
            Button(action: {note = notes.randomElement()!}, label: {
                Circle()
                    .fill(.gray)
                    .frame(width: 54.0)
                    .overlay(Text(note).foregroundStyle(.black))
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
