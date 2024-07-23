//
//  RecordingFrequencies.swift
//  JustDrones
//
//  Created by Eli Pouliot on 7/5/24.
//

import Foundation
import SwiftUI

struct RecordedDrone: Identifiable, Codable {
    let id: UUID
    let frequency:Double
    let noteName:String
    let pitchClass:String
    
    init(id: UUID = UUID(), frequency: Double, noteName: String, pitchClass: String) {
        self.id = id
        self.frequency = frequency
        self.noteName = noteName
        self.pitchClass = pitchClass
    }
}

struct Preset: Identifiable, Codable {
    var id = UUID()
    let name: String
    let list: Array<RecordedDrone>
}

class RecordingManager : ObservableObject {
    @Published var recorded: Array<RecordedDrone>
    @Published var recording: Bool
    
    @Published var presets: Array<Preset> {
        didSet {
            save()
        }
    }
    private let PresetKey = "PresetKey"
    
    
    init() {
        recorded = [RecordedDrone]()
        recording = false
        
        if let data = UserDefaults.standard.data(forKey: PresetKey) {
            if let decoded = try? JSONDecoder().decode([Preset].self, from: data) {
                presets = decoded
                return
            }
        }
        presets = []
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: PresetKey)
        }
    }
    
    func clear() {
        recorded = []
    }
    
    func add(name: String, list: Array<RecordedDrone>) {
        presets.append(Preset(name: name, list: list))
    }
    
    func load(key: String) {
        recorded = presets.first(where: {entry in
            entry.name == key})?.list ?? []
    }
    
}

@available(iOS 17.0, *)
struct Recorded: View {
    
    let diapason: Int
    let stop: Int
    let displayMode: DisplayMode
    @ObservedObject var recorder: RecordingManager
    @ObservedObject var synth: SynthManager
    
    var isPedal: Bool
    
    
    @State private var isTapped: Bool = false
    
    @State private var name: String = ""
    
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
    
    @State private var isSavePopUpOpen = false
    @State private var isSavedListsOpen = false
    
    @State private var NavigationState = NavigationSplitViewColumn.detail
    
    var body: some View {
        
        GeometryReader {geometry in
            let midX = geometry.size.width / 2.0
            let midY = geometry.size.height / 2.0
            
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
                        ScrollView(.horizontal, showsIndicators: false) {
                            GeometryReader {geo in
                                LazyHStack(spacing: 0) {
                                    ForEach(recorder.recorded) {drone in
                                        Drone(noteName: drone.noteName, pitchClass: drone.pitchClass, diapason: diapason, stop: stop, displayMode: displayMode, frequency: drone.frequency, synth: synth, recorder: recorder)
                                    }
                                }
                                .containerRelativeFrame(.horizontal, alignment: .center)
                            }
                        }
                        .frame(height: 54)
                        
                        
                        if isPedal {
                            PedalDrone(isTapped: $isTapped, synth: synth, recorder: recorder, displayMode: displayMode)
                        }
                    }
                    
                    
                    
                    if recorder.recorded.count > 0 {
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
                    }
                }
            }
        }
    }
}

struct SavePopUp: View {
    @Binding var isSavePopUpOpen: Bool
    @State var name = ""
    @ObservedObject var recorder: RecordingManager
    
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
    @Binding var isTapped: Bool
    @ObservedObject var synth: SynthManager
    @ObservedObject var recorder: RecordingManager
    @FocusState private var isFocused: Bool
    
    var displayMode: DisplayMode
    
    @SceneStorage("Recorded.index")
    private var index = 0
    
    private func forward() {
        index += 1
    }
    private func backward() {
        index -= 1
    }
    private func reset() {
        index = 0
    }
    
    private var overlayer: String {
        if index >= 0 && index < recorder.recorded.count {
            return label(Drone: recorder.recorded[index])
        } else {return ""}
    }
    
    private func label(Drone: RecordedDrone) -> String {
        switch displayMode {
        case .frequency:
            return "\(String(format: "%.1f", Drone.frequency))"
        case .noteName:
            return Drone.noteName
        case .pitchClass:
            return Drone.pitchClass
        }
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            let circleColor = isTapped ? Color.accentColor : Color.gray
            Button(action: {
                isTapped.toggle()
                if !isTapped {synth.stopPlaying1()}
                if isTapped { if index >= 0 && index < recorder.recorded.count {synth.playRecordPitch(frequency: recorder.recorded[index].frequency)} else {isTapped = false}}
            })
            {
                Circle()
                    .fill(circleColor)
                    .frame(width: 27.0 * 2, height: 27.0 * 2)
                    .overlay(
                        DroneLabel(label: overlayer))
            }
            .focusable()
            .focused($isFocused)
            .focusEffectDisabled()
            .onKeyPress(keys: [KeyEquivalent.downArrow, KeyEquivalent.leftArrow], action: { press in
                if index >= 0 && index < recorder.recorded.count - 1 {
                    forward()
                    if isTapped{
                        synth.playRecordPitch(frequency: recorder.recorded[index].frequency)
                    }
                } else if index == recorder.recorded.count - 1 {
                    synth.stopPlaying1()
                    isTapped = false
                }
                return .handled
            })
            .onKeyPress(keys: [KeyEquivalent.upArrow, KeyEquivalent.rightArrow], action: { press in
                if index > 0 && index < recorder.recorded.count {
                    backward()
                    if isTapped {
                        synth.playRecordPitch(frequency: recorder.recorded[index].frequency)
                    }
                } else if index == 0 {
                    synth.stopPlaying1()
                    isTapped = false
                }
                return .handled
            })
            .onAppear() {
                isFocused = true
                reset()
            }
        }
    }
}
