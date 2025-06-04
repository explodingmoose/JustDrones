//
//  ControlMenu.swift
//  JustDrones
//
//  Created by Eli Pouliot on 6/4/25.
//

import SwiftUI

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
                            Text("Notation System:")
                            Picker("Note Name", selection: $namingMode) {
                                ForEach(NamingMode.allCases) { language in
                                    Text(language.rawValue)
                                }
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
