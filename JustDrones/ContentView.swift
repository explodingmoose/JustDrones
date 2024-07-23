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

struct ContentView: View {
    @ObservedObject var theSynth = SynthManager()
    @ObservedObject var theRecorder = RecordingManager()
    
    @State private var isSynthMenuOpen = false
    @State private var isControlMenuOpen = false
    @State private var isRandomMenuOn = false
    
    @SceneStorage("Recorded.isPedal")
        private var isPedal = true
    
    @State private var diapason = 441
    @State private var stop = 16
    
    @AppStorage("ContentView.displayMode")
        private var displayMode = DisplayMode.noteName
    @AppStorage("ContentView.tuningMode")
        private var tuningMode = TuningMode.Tonnetz
    
    var body: some View {
        ZStack{
            VStack {
                
                //Drone views
                VStack(spacing: 5) {
                    if tuningMode == .Tonnetz {
                        Tonnetz(diapason: diapason, stop: stop, displayMode: displayMode, synth: theSynth, recorder: theRecorder)
                    } else if tuningMode == .CircleFifths {
                        CircleOfFifths(diapason: diapason, stop: stop, displayMode: displayMode, synth: theSynth, recorder: theRecorder)
                    } else if tuningMode == .Recorded {
                        if #available(iOS 17.0, *) {
                            Recorded(diapason: diapason, stop: stop, displayMode: displayMode, recorder: theRecorder, synth: theSynth, isPedal: isPedal)
                                .onAppear() {theRecorder.recording = false}
                        }
                    }
                }

                //Buttons for menus
                HStack(alignment: .center, spacing: 20) {
                    Button(action: {
                        isControlMenuOpen.toggle()
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        isSynthMenuOpen.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        isRandomMenuOn.toggle()
                    }) {
                        Image(systemName: "dice")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        theRecorder.recording.toggle()
                    }) {
                        if theRecorder.recording {
                            Image(systemName: "stop.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.red)} else {
                            Image(systemName: "record.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                            }
                    }
                }
            }
            
            if isSynthMenuOpen {SynthMenu(synth: theSynth, isSynthMenuOpen: $isSynthMenuOpen)}
            if isControlMenuOpen {ControlMenu(isControlMenuOpen: $isControlMenuOpen, displayMode: $displayMode, tuningMode: $tuningMode, diapason: $diapason, stop: $stop, isPedal: $isPedal)}
            if isRandomMenuOn {RandomMenu(isRandomMenuOn: $isRandomMenuOn)}
            
        }
    }
    
}

