//
//  OscillatorParameters.swift
//  JustDrones
//
//  Created by Eli Pouliot on 5/30/25.
//



struct OscillatorParameters: Codable {
    //Oscillators
    var shapebalance: Float = 0.5
    var O1Morph: Float = 0.0 //Default sine wave
    var O2Morph: Float = 0.0 //Default sine wave
}
struct SubParameters: Codable {
    //Sub Osc
    var isSub: Bool = true
    var subOctave: SubOctave = .Ottava
    /*
     var isSquare: Bool = false
     var subGain: Float = 0.0 //dB to be added?
     */
}
struct FilterParameters: Codable {
    //Filter
    var isFilter: Bool = true
    var cutoffFrequency: Float = 0.75 // Scaled down by 2000
    var resonance: Float = 0.50
}
struct PhaserParameters {
    //Phaser
    var isPhaser: Bool = false
    var notchFloor: Float = 1000
    var notchCeiling: Float = 5000
    var notchFrequency: Float = 1.5
    var phaserDepth: Float = 50
    var phaserFeedback: Float = 0
    var lfoBPM: Float = 30.0
}
struct LFOParameters {
    //LFO Parameters
    var lfofrequency: Float = 1
    var lfoamplitude: Float = 1000
    var lfoindex: Float = 0.0
}
struct MasterParameters {
    //Master
    var masterGain: Float = 0 //-12...6 dB
}