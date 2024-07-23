//
//  Menus.swift
//  JustDrones
//
//  Created by Eli Pouliot on 8/26/23.
//

import Foundation
import SwiftUI
import AudioKit
import Controls

struct SynthMenu: View {
    @ObservedObject var synth: SynthManager
    @Binding var isSynthMenuOpen: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 15) {
                    HStack {
                        GeometryReader { proxy in
                            XYPad(x: $synth.cutoffFrequency, y: $synth.resonance)
                                .backgroundColor(.primary)
                                .foregroundColor(.accentColor)
                                .indicatorSize(CGSize(width: 10, height: 10))
                                .cornerRadius(20)
                        }
                        VStack (alignment: .center, spacing: 15) {
                            VStack {
                                Text("Cutoff: \(Int(synth.cutoffFrequency * 2000))")
                                Slider(value: $synth.cutoffFrequency, in: 0...1, step: 0.0005)
                            }
                            Divider()
                            VStack {
                                Text("Resonance: \(String(format: "%.2f", synth.resonance))")
                                Slider(value: $synth.resonance, in: 0...1, step: 0.01)
                            }
                        }
                    }
                    
                    Divider()

                    HStack {
                        VStack{
                            Text("Shape 1")
                            Picker("Oscillator 1 Shape", selection: $synth.FirstShape) {
                                Text("Sine:").tag(OscillatorShapes.sine)
                                Text("Square").tag(OscillatorShapes.square)
                                Text("Saw").tag(OscillatorShapes.saw)
                                Text("Triangle").tag(OscillatorShapes.triangle)
                            }
                        }
                        Slider(value: $synth.shapebalance, in: 0...1, step: 0.01)
                        VStack{Text("Shape 2")
                            Picker("Oscillator 2 Shape", selection: $synth.SecondShape) {
                                Text("Sine:").tag(OscillatorShapes.sine)
                                Text("Square").tag(OscillatorShapes.square)
                                Text("Saw").tag(OscillatorShapes.saw)
                                Text("Triangle").tag(OscillatorShapes.triangle)
                            }
                        }
                    }

                    Button(action: {
                        isSynthMenuOpen.toggle()
                    }) {
                        Text("Close")
                            .foregroundColor(.blue)
                    }
                    .padding(5)
                }
                .padding()
                .background()
                .cornerRadius(10)
                .shadow(radius: 4)
            }
        }
        .padding()
        
    }
}

struct ControlMenu: View {
    let diapasons = [415, 423, 432, 436, 439, 440, 441, 442, 443, 444, 445, 446]
    let stops = [2, 4, 8, 16, 32, 64]
    
    @Binding var isControlMenuOpen: Bool
    
    @Binding var displayMode: DisplayMode
    @Binding var tuningMode: TuningMode
    @Binding var diapason: Int
    @Binding var stop: Int
    @Binding var isPedal: Bool
    
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
                    .padding()
                    
                    VStack {
                        HStack(spacing: 10) {
                            Text("Diapason:")
                            Picker("Standard A4", selection: $diapason) {
                                ForEach(diapasons, id: \.self) {
                                    Text("\(String($0)) Hz")
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        HStack(spacing: 10) {
                            Text("Stop:")
                            Picker("Standard A4", selection: $stop) {
                                ForEach(stops, id: \.self) {
                                    Text("\(String($0))'")
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        HStack(spacing: 10) {
                            Text("Display Mode:")
                            Picker("Display Mode", selection: $displayMode) {
                                Text("Pitch Class").tag(DisplayMode.pitchClass)
                                Text("Frequency").tag(DisplayMode.frequency)
                                Text("Note Name").tag(DisplayMode.noteName)
                            }
                            .pickerStyle(.menu)
                        }
                        
                        HStack(spacing: 20) {
                            Text("Pedal:")
                            Toggle("Pedal:", isOn: $isPedal)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .labelsHidden()
                        }
                    }
                    .padding()
                    
                    Button(action: {
                        isControlMenuOpen.toggle()
                    }) {
                        Text("Close")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
                .position(x: midx, y: midy)
            }
        }
        .background()
        .cornerRadius(16)
        .padding()
        .shadow(radius: 4)
        .zIndex(2)
    }
}

struct RandomMenu: View {
    @Binding var isRandomMenuOn: Bool
    @State var note = "Go"
    let notes = ["A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"]
    
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
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}
