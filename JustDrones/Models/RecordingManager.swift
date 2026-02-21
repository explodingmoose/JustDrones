//
//  Preset.swift
//  JustDrones
//
//  Created by Eli Pouliot on 5/30/25.
//

import SwiftUI

struct Preset: Identifiable, Codable {
    var id = UUID()
    let name: String
    let list: Array<Drone>
}

@Observable class RecordingManager {
    var recorded: Array<Drone>
    var recording: Bool
    var pedalDroneIndex: Int = 0
    var presets: Array<Preset> {
    didSet {
        save()
    }
}
    private let PresetKey = "PresetKey"
    
    
    init() {
        recorded = [Drone]()
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
    
    func add(name: String, list: Array<Drone>) {
        presets.append(Preset(name: name, list: list))
    }
    
    func load(key: String) {
        recorded = presets.first(where: {entry in
            entry.name == key})?.list ?? []
    }
    
}
