//
//  ContentView.swift
//  JustDrones
//
//  Created by Eli Pouliot on 8/26/23.
//

import SwiftUI


enum DisplayMode: String {
    case pitchClass
    case frequency
    case noteName
}
enum TuningMode: String {
    case Tonnetz
    case CircleFifths
    case Recorded
}
enum NamingMode: String, CaseIterable, Identifiable {
    case English
    case Solfège
    case Deutsch
    case Nederlands
    var id: Self { self }
}

struct ContentView: View {
    //TODO: it would be good to organize the variables to be in the same order consistently
    @State private var theSynth = SynthManager()
    @State private var theRecorder = RecordingManager()
    @State private var theDroneManager = DroneManager()
    
    @SceneStorage("ContentView.synthMenu") private var isSynthMenuOpen = false
    @SceneStorage("ContentView.controlMenu") private var isControlMenuOpen = false
    @SceneStorage("ContentView.randomMenu") private var isRandomMenuOn = false
    @SceneStorage("Recorded.isPedal") private var isPedal = true
    @SceneStorage("ContentView.displayMode") private var displayMode = DisplayMode.noteName
    @SceneStorage("ContentView.tuningMode") private var tuningMode = TuningMode.Tonnetz
    
    var drones: some View {
        VStack(spacing: 5) {
            switch tuningMode {
            case .Tonnetz:
                Tonnetz(displayMode: displayMode, synth: theSynth, recorder: theRecorder, droneManager: theDroneManager)
            case .CircleFifths:
                CircleOfFifths(displayMode: displayMode, synth: theSynth, recorder: theRecorder, droneManager: theDroneManager)
            case .Recorded:
                Recorded(diapason: 440, stop: 16, displayMode: displayMode, recorder: theRecorder, synth: theSynth, isPedal: isPedal)
                    .onAppear() {theRecorder.recording = false}
            }
        }
    }
    var buttons: some View {
        HStack(alignment: .center, spacing: 20) {
            Button(action: {
                isControlMenuOpen.toggle()
            }) {
                Image(systemName: "gear")
                    .iconStyle()
            }
            
            Button(action: {
                isSynthMenuOpen.toggle()
            }) {
                Image(systemName: "slider.horizontal.3")
                    .iconStyle()
            }
            
            Button(action: {
                isRandomMenuOn.toggle()
            }) {
                Image(systemName: "dice")
                    .iconStyle()
            }
            
            Button(action: {
                theRecorder.recording.toggle()
            }) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: 24))
                        .foregroundStyle(theRecorder.recording ? .red : Color.accentColor)
                    
            }
        }
    }
    var menu: some View {
        ZStack{
            if isSynthMenuOpen {SynthMenu(synth: theSynth, isSynthMenuOpen: $isSynthMenuOpen)}
            if isControlMenuOpen {ControlMenu(droneManager: theDroneManager, synth: theSynth, isControlMenuOpen: $isControlMenuOpen, displayMode: $displayMode, tuningMode: $tuningMode, isPedal: $isPedal)}
            if isRandomMenuOn {RandomMenu(isRandomMenuOn: $isRandomMenuOn)}
        }
    }
    
    var body: some View {
        ZStack{
            VStack {
                //Drone views
                drones
                //Buttons for menus
                buttons
            }
            //Menu displays
            menu
        }
    }
}

