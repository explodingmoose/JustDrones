//
//  RecordingFrequencies.swift
//  JustDrones
//
//  Created by Eli Pouliot on 7/5/24.
//

import SwiftUI


struct Recorded: View {
    
    let diapason: Int
    let stop: Int
    let displayMode: DisplayMode
    var recorder: RecordingManager
    let synth: SynthManager
    var isPedal: Bool
    
    @State private var isSavePopUpOpen = false
    @State private var isSavedListsOpen = false
    @State private var NavigationState = NavigationSplitViewColumn.detail
    
    private func load(key: String) -> () -> () {
        return {
            NavigationState = NavigationSplitViewColumn.detail
            recorder.load(key: key)
        }
    }
    private func clear() -> () -> () {
        return {
            NavigationState = NavigationSplitViewColumn.detail
            recorder.clear()
        }
    }
    
    var body: some View {
        
        GeometryReader {geometry in
            let midX = geometry.size.width / 2.0
            let midY = geometry.size.height / 2.0
            
            //TODO: Is this Geometry Reader Necessary?
            
            if isSavePopUpOpen {
                SavePopUp(isSavePopUpOpen: $isSavePopUpOpen, recorder: recorder)
                    .position(x: midX, y: midY)
            }
            VStack{
                NavigationSplitView(preferredCompactColumn: $NavigationState) {
                    List {
                        HStack{
                            Text("New")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture(perform: clear())
                        
                        Section("User") {
                            ForEach(recorder.presets) { entry in
                                HStack{
                                    Text(entry.name)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture(perform: load(key: entry.name))
                            }
                            .onDelete { recorder.presets.remove(atOffsets: $0) }
                            .onMove { recorder.presets.move(fromOffsets: $0, toOffset: $1) }
                            .navigationTitle("Presets")
                        }
                        
                    }
                    .listStyle(.insetGrouped)
                    .toolbar {
                        EditButton()
                    }
                } detail: {
                    if recorder.recorded.count == 0 {
                        Text("Nothing here yet")
                    } else {
                        //Recorded drone list
                        ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 0) {
                                    ForEach(recorder.recorded) {drone in
                                        DroneButton(drone: drone, displayMode: displayMode, recorder: recorder, synth:synth, droneRadius: 27.0)
                                    }
                                }
                                .containerRelativeFrame(.horizontal, alignment: .center)
                        }
                        .frame(height: 54)
                        
                        //Clear and Save Buttons
                        HStack{
                            Button(action: {
                                recorder.clear()
                            }) {
                                Text("Clear")
                            }
                            Button(action: {
                                isSavePopUpOpen = true
                            }) {
                                Text("Save")
                            }
                        }
                        
                        if isPedal {
                            VStack {
                                Text("Drone for Pedal Use:")
                                PedalDrone(synth: synth, recorder: recorder, displayMode: displayMode)
                            }}
                    }
                }
            }
        }
    }
}

struct SavePopUp: View {
    @Binding var isSavePopUpOpen: Bool
    @State var name = ""
    var recorder: RecordingManager
    
    var body: some View {
        VStack{
            Text("Save As:")
            TextField(
                "Name",
                text: $name
            )
            Divider()
            
            HStack {
                Button(action: {
                    if name != "" {
                        if !recorder.presets.contains(where: { entry in
                            entry.name == name
                        }) {
                            recorder.add(name: name, list: recorder.recorded)
                            isSavePopUpOpen = false
                        }
                    }
                }) {
                    Text("Save")
                }
                .padding()
                Button(action: {
                    isSavePopUpOpen = false
                    name = ""
                }) {
                    Text("Cancel")
                }
                .padding()
            }
        }
        .padding()
        .background()
        .frame(width: 200)
        .cornerRadius(10)
        .shadow(radius: 4)
        .zIndex(2)
    }
}

struct PedalDrone: View {
    var synth: SynthManager
    let recorder: RecordingManager
    let displayMode: DisplayMode
    
    @State private var isTapped = false
    @FocusState private var isFocused: Bool
    
    @SceneStorage("Recorded.index") private var index = 0
    
    private func forward() {
        index += 1
        updateQueue(recorder.recorded[index])
    }
    private func backward() {
        index -= 1
        updateQueue(recorder.recorded[index])
    }
    private func reset() {
        index = 0
    }
    
    //labels the pedal button to keep with the current index
    private var overlayer: String {
        if index >= 0 && index < recorder.recorded.count {
            return label(Drone: recorder.recorded[index])
        } else {return ""}
    }
    private func label(Drone: Drone) -> String {
        switch displayMode {
        case .frequency:
            return "\(String(format: "%.1f", Drone.frequency))"
        case .noteName:
            return Drone.noteName
        case .pitchClass:
            return Drone.pitchClass
        }
    }
    
    //mirrors the usual synth.queue, to avoid publishing changes as same time as view updates
    @State private var tempQueue: [Drone] = []
    
    private func turnOn() {
        tempQueue.append(recorder.recorded[index])
    }
    private func updateQueue(_ drone: Drone) {
        if isTapped {
            tempQueue[0] = drone
        }
    }
    private func turnOff() {
        tempQueue = []
        isTapped = false
    }
    
    var body: some View {
            let circleColor = isTapped ? Color.accentColor : Color.gray
            Button(action: {
                isTapped.toggle()
                if !isTapped {synth.clearQueue()} else {turnOn()}
            })
            {
                if recorder.recorded.isEmpty {EmptyView()} else {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 27.0 * 2, height: 27.0 * 2)
                        .overlay(
                            ButtonLabel(displayMode: displayMode, frequency: recorder.recorded[index].frequency, noteName: recorder.recorded[index].noteName, pitchClass: recorder.recorded[index].pitchClass))
                }
            }
            .focusable()
            .focused($isFocused)
            .focusEffectDisabled()
            .onKeyPress(keys: [KeyEquivalent.downArrow, KeyEquivalent.rightArrow], action: { press in
                if index >= 0 && index < recorder.recorded.count - 1 {
                    forward()
                } else if index == recorder.recorded.count - 1 {
                    turnOff()
                }
                return .handled
                     
            })
            .onKeyPress(keys: [KeyEquivalent.upArrow, KeyEquivalent.leftArrow], action: { press in
                if index > 0 && index < recorder.recorded.count {
                    backward()
                } else if index == 0 {
                    turnOff()
                }
                return .handled
            })
            .onChange(of: tempQueue) {
                synth.queue = tempQueue
            }
            .onAppear() {
                isFocused = true
                reset()
            }
        
    }
}
