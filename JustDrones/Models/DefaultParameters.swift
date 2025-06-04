//
//  DefaultParameters.swift
//  JustDrones
//
//  Created by Eli Pouliot on 6/1/25.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UserDefaults.standard.register(defaults: [
            // tuning parameters //
            "drones.diapason": 440,
            "drones.stop": 16,
            "drones.temperedfifth": 1.5,
            // synth parameters //
            "synth.isPhaser": false,
            "synth.isFilter": true,
            "synth.isLFO": true,
            "synth.isSub": true,
            "synth.shapeBalance": 0.5,
            "synth.O1Morph": 0.0,
            "synth.O2Morph": 0.0,
            "synth.subOctave": 0.5,
            "synth.cutoffFrequency": 0.75,
            "synth.resonance": 0.25,
            "synth.lfoFrequency": 1.0,
            "synth.lfoDepth": 1000.0,
            "synth.lfoIndex": 0.0,
            "synth.notchFloor": 1000.0,
            "synth.notchCieling": 5000.0,
            "synth.notchFrequency": 1.5,
            "synth.phaserDepth": 50,
            "synth.phaserFeedback": 20.0,
            "synth.lfoBPM": 30.0,
            "synth.compressorGain": 0.0
        ])
        return true
    }
}

