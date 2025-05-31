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
    @ObservedObject var synth: SynthManager
    @Binding var isSynthMenuOpen: Bool
    
    @State private var isSubOscMenuOpen: Bool = false
    @State private var isFilterMenuOpen: Bool = false
    @State private var isLFOMenuOpen: Bool = false
    @State private var isPhaserMenuOpen: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 50) {
                    VStack{
                        //Presets
                        Text("Osc 1:")
                        HStack {
                            Image("Sine")
                                .font(.system(size: 24))
                                .foregroundColor(.accent)
                                .onTapGesture{synth.O1Morph = 0}
                            Image("Triangle")
                                .font(.system(size: 24))
                                .foregroundColor(.accent)
                                .onTapGesture{synth.O1Morph = 1}
                            Image("Square")
                                .font(.system(size: 24))
                                .foregroundColor(.accent)
                                .onTapGesture{synth.O1Morph = 2}
                            Image("Sawtooth")
                                .font(.system(size: 24))
                                .foregroundColor(.accent)
                                .onTapGesture{synth.O1Morph = 3}
                        }
                        SmallKnob(value: $synth.O1Morph, range: 0...3)
                            .frame(width: 50, height: 50)
                        Text("Morph: \(String(format: "%.2f", synth.O1Morph/3))")
                    }
                    VStack{
                        Slider(value: $synth.shapebalance, in: 0...1, step: 0.01)
                            .frame(width: 200)
                        RawOutputView(synth.voiceMixer, strokeColor: .accent, scaleFactor: 0.5)
                            .frame(width: 200, height: 100)
                            .border(.accent, width: 0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                    VStack{
                        //Presets
                        Text("Osc 2:")
                        HStack {
                            Image("Sine")
                                .font(.system(size: 24))
                                .foregroundColor(.accent)
                                .onTapGesture{synth.O2Morph = 0}
                            Image("Triangle")
                                .font(.system(size: 24))
                                .foregroundColor(.accent)
                                .onTapGesture{synth.O2Morph = 1}
                            Image("Square")
                                .font(.system(size: 24))
                                .foregroundColor(.accent)
                                .onTapGesture{synth.O2Morph = 2}
                            Image("Sawtooth")
                                .font(.system(size: 24))
                                .foregroundColor(.accent)
                                .onTapGesture{synth.O2Morph = 3}
                        }
                        SmallKnob(value: $synth.O2Morph, range: 0...3)
                            .frame(width: 50, height: 50)
                        Text("Morph: \(String(format: "%.2f", synth.O2Morph/3))")
                    }
                }
                
                Divider()
                //Master knob
                VStack(alignment: .subCentre) {
                    HStack {
                        VStack {
                            Text("Master:")
                            SmallKnob(value: $synth.masterGain, range: -12...6)
                                .frame(height: 50)
                            Text("\(String(format: "%.2f", synth.masterGain)) dB")
                        }
                        Spacer().frame(width: 50)
                        Divider ()
                            .alignmentGuide(.subCentre) { d in d.width/2 }
                        Spacer().frame(width: 50)
                        VStack {
                            Button(action: {isSubOscMenuOpen.toggle()}) {Text("Sub Oscillator")}
                            Button(action: {isLFOMenuOpen.toggle()}) {Text("LFO")}
                            Button(action: {isFilterMenuOpen.toggle()}) {Text("Filter")}
                            Button(action: {isPhaserMenuOpen.toggle()}) {Text("Phaser")}
                        }
                    }
                    GeometryReader { geometry in
                        EmptyView()
                    }
                    .alignmentGuide(.subCentre) { d in d.width/2 }
                }
                //Close menu button
                Button(action: {isSynthMenuOpen.toggle()}) {Text("Close")
                        .foregroundColor(.blue)
                }
                .padding(5)
            }
            .padding()
            .background()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 4)
            
            .padding()
            if isSubOscMenuOpen {SubOscMenu(isSubOscMenuOpen: $isSubOscMenuOpen, synth: synth)}
            if isFilterMenuOpen {FilterMenu(isFilterMenuOpen: $isFilterMenuOpen, synth: synth)}
            if isLFOMenuOpen {LFOMenu(isLFOMenuOpen: $isLFOMenuOpen, synth: synth)}
            if isPhaserMenuOpen {PhaserMenu(isPhaserMenuOpen: $isPhaserMenuOpen, synth: synth)}
        }
    }
}
struct ControlMenu: View {
    private let diapasons = [415, 422, 423, 432, 435, 436, 439, 440, 441, 442, 443, 444, 445, 446]
    private let stops = [2, 4, 8, 16, 32, 64]
    @ObservedObject var droneManager: DroneManager
    @ObservedObject var synth: SynthManager
    
    @Binding var isControlMenuOpen: Bool
    @Binding var displayMode: DisplayMode
    @Binding var tuningMode: TuningMode
    @Binding var isPedal: Bool
    
    var body: some View {
        VStack (alignment: .center){
            GeometryReader { geometry in
                let midx = geometry.size.width / 2.0
                let midy = geometry.size.height / 2.0
                VStack {
                    
                    if #available(iOS 17.0, *) {
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
                    } else {
                        Text("Please update to iOS 17.0 or higher!")
                    }
                    
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
                        
                        
                        HStack(spacing: 20) {
                            Text("Pedal:")
                            Toggle("Pedal:", isOn: $isPedal)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .labelsHidden()
                        }
                        
                        Button(action: {
                            synth.clearQueue()
                        }) {
                            Text("Stop All Drones!")
                                .foregroundColor(.accentColor)
                        }
                        .padding()
                        
                    }
                    
                    Button(action: {
                        isControlMenuOpen.toggle()
                    }) {
                        Text("Close")
                            .foregroundColor(.blue)
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
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
}
