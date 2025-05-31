//
//  Synth.swift
//  JustDrones
//
//  Created by Eli Pouliot on 8/26/23.
//

import Foundation
import AudioKit
import SoundpipeAudioKit
import AudioKitEX
import DunneAudioKit
import SporthAudioKit

struct Voice {
    let tableArray = [Table(.sine), Table(.triangle), Table(.square), Table(.sawtooth)]
    var DCO1: MorphingOscillator
    var DCO2: MorphingOscillator
    var subOsc = DynamicOscillator(waveform: Table(.sine))
    var voiceMixer: DryWetMixer
    
    func setSubOscShape(_ table: TableType) {
        subOsc.setWaveform(Table(table))
    }
    
    init() {
        DCO1 = MorphingOscillator(waveformArray: tableArray)
        DCO2 = MorphingOscillator(waveformArray: tableArray)
        voiceMixer = DryWetMixer(dry: DCO1, wet: DCO2, balance: AUValue(0.50))
    }
}

class SynthManager: ObservableObject {
    
    var voice1 = Voice()
    var voice2 = Voice()
    var voice3 = Voice()
    var voice4 = Voice()
    var voiceArray: [Voice] = []
    
    var voiceMixer: Mixer
    var subMixer: Mixer
    var filter: OperationEffect
    var phaser: Phaser
    var compressor: Compressor
    var engine: AudioEngine
    
    
    //to allow bypass
    var isPhaser: Bool = true //phaser effect
    var isFilter: Bool = true //Moog Ladder filter (low pass)
    @Published var isSub: Bool = true {
        didSet {
            if isSub {voiceMixer.addInput(subMixer)} else {voiceMixer.removeInput(subMixer)}
            updateQueue()
        }
    }//Sub Oscillator (sine wave at octave below)
    
    //Drones that are on
    @Published var queue: [Drone] {
        didSet {
            updateQueue()
        }
    }
    
    //Oscillator Parameters
    private func updateDCObalance(_ shapebalance: Float) {
            let balance = AUValue(shapebalance)
            voiceArray.forEach { voice in
                voice.voiceMixer.balance = balance
            }
        }
    @Published var shapebalance: Float = 0.5 {
        didSet{
            updateDCObalance(shapebalance)
            UserDefaults.standard.set(String(shapebalance), forKey: "shapebalance")
        }
    }
    @Published var O1Morph: Float = 0.0 {
        didSet {
            voiceArray.forEach { voice in
                voice.DCO1.index = O1Morph
            }
            UserDefaults.standard.set(String(O1Morph), forKey: "O1Morph")
        }
    }
    @Published var O2Morph: Float = 0.0 {
        didSet {
            voiceArray.forEach { voice in
                voice.DCO2.index = O2Morph
            }
            UserDefaults.standard.set(String(O2Morph), forKey: "O2Morph")
        }
    }
    
    //SubOsc Parameters
    @Published var subOctave: SubOctave = .Ottava {
        didSet {
            updateQueue()
            UserDefaults.standard.set(String(subOctave.rawValue), forKey: "subOctave")
        }
    }
    private func subOctaveRatio() -> Float {
        switch subOctave {
        case .Ottava:
            return 2
        case .Quindicecisma:
            return 4
        }
    }

    //Filter Parameters
    @Published var cutoffFrequency: Float = 0.75 {
        didSet {
            filter.parameter1 = AUValue(cutoffFrequency * 2000)
            UserDefaults.standard.set(String(cutoffFrequency), forKey: "cutoff")
        }
    }
    @Published var resonance: Float = 0.50 {
        didSet {
            filter.parameter2 = AUValue(resonance)
            UserDefaults.standard.set(String(resonance), forKey: "resonance")
        }
    }
        
    //Phaser Parameters
    @Published var notchFloor: Float = 1000 {
        didSet {
            //20 - 5000Hz
            phaser.notchMinimumFrequency = AUValue(notchFloor)
            UserDefaults.standard.set(String(notchFloor), forKey: "notchFloor")
        }
    }
    @Published var notchCeiling: Float = 5000 {
        didSet {
            //20 - 10000Hz
            phaser.notchMaximumFrequency = AUValue(notchCeiling)
            UserDefaults.standard.set(String(notchCeiling), forKey: "notchCeiling")
        }
    }
    @Published var notchFrequency: Float = 1.5 {
        didSet {
            //1.1-4Hz
            phaser.notchFrequency = AUValue(notchFrequency)
            UserDefaults.standard.set(String(notchFrequency), forKey: "notchFrequency")
        }
    }
    @Published var phaserDepth: Float = 50 {
        didSet {
            //0-1
            phaser.depth = AUValue(phaserDepth/100)
            UserDefaults.standard.set(String(phaserDepth), forKey: "phaserDepth")
        }
    }
    @Published var phaserFeedback: Float = 0 {
        didSet {
            phaser.feedback = AUValue(phaserFeedback/100)
            UserDefaults.standard.set(String(phaserFeedback), forKey: "phaserFeedback")
        }
    }
    @Published var lfoBPM: Float = 30.0 {
        didSet {
            //24 - 360 BPM
            phaser.lfoBPM = AUValue(lfoBPM)
            UserDefaults.standard.set(String(lfoBPM), forKey: "lfoBPM")
        }
    }
    
    //LFO Parameters
    @Published var lfofrequency: Float = 1 {
        didSet {
            filter.parameter4 = AUValue(lfofrequency)
            UserDefaults.standard.set(String(lfofrequency), forKey: "lfofrequency")
        }
    }
    @Published var lfoamplitude: Float = 1000 {
        didSet {
            //in hz
            filter.parameter3 = AUValue(lfoamplitude)
            UserDefaults.standard.set(String(lfoamplitude), forKey: "lfoamplitude")
        }
    }
    @Published var lfoindex: Float = 0.0 {
        didSet {
            filter.parameter5 = AUValue(lfoindex)
            UserDefaults.standard.set(String(lfoindex), forKey: "lfoindex")
        }
    }
    
    //Master
    @Published var masterGain: Float = 0 {
        didSet {
            compressor.masterGain = AUValue(masterGain)
        }
    }
    
    init() {
        engine = AudioEngine()
        //4 voice polyphony
        voiceMixer = Mixer(voice1.voiceMixer, voice2.voiceMixer, voice3.voiceMixer, voice4.voiceMixer)
        subMixer = Mixer(voice1.subOsc, voice2.subOsc, voice3.subOsc, voice4.subOsc)
        
        //phaser effect
        phaser = Phaser(voiceMixer, vibratoMode: 0)
        phaser.stop()
        //filter with LFO on cutoff
        filter = OperationEffect(phaser) { input, parameters in
            
            let cutoff = parameters[0]
            let rez = parameters[1]
            let oscAmp = parameters[2]
            let oscRate = parameters[3]
            let oscIndex = parameters[4]

            let lfo = Operation.morphingOscillator(frequency: oscRate,
                                                     amplitude: oscAmp,
                                                     index: oscIndex)

            return input.moogLadderFilter(cutoffFrequency: max(lfo + cutoff, 0),
                                          resonance: rez)
        }
        filter.stop()
        
        compressor = Compressor(filter)
        engine.output = compressor
        
        //set up audio engine
        do {
            try engine.start()
        } catch {
            print("Failed to start AudioEngine: \(error)")
        }
        do {
            try Settings.setSession(category: .playback)
        } catch {
            print("error")
        }
        engine.output!.start()
        
        
        voiceArray = [voice1, voice2, voice3, voice4]
        queue = []
        
        filter.parameter1 = AUValue(cutoffFrequency * 2000)
        filter.parameter2 = AUValue(resonance)
        filter.parameter3 = AUValue(lfoamplitude)
        filter.parameter4 = AUValue(lfofrequency)
        compressor.masterGain = AUValue(masterGain)
        
        voiceMixer.addInput(subMixer)

        //recall previous waveform settings
        if let decoded = UserDefaults.standard.string(forKey: "O1Morph") {
            O1Morph = Float(decoded) ?? 0.0
        }
        if let decoded = UserDefaults.standard.string(forKey: "O2Morph") {
            O2Morph = Float(decoded) ?? 0.0
        }
        if let decoded = UserDefaults.standard.string(forKey: "shapebalance") {
            shapebalance = Float(decoded) ?? 0.50
            updateDCObalance(shapebalance)
        }
        
        //recall previous filter settings
        if let decoded = UserDefaults.standard.string(forKey: "cutoff") {
            cutoffFrequency = Float(decoded) ?? 0.75
            filter.parameter1 = AUValue(cutoffFrequency * 2000)
        }
        if let decoded = UserDefaults.standard.string(forKey: "resonance") {
            resonance = Float(decoded) ?? 0.50
            filter.parameter2 = AUValue(resonance)
        }
                
        //recall previous phaser settings
        if let decoded = UserDefaults.standard.string(forKey: "notchFloor") {
            phaser.notchMinimumFrequency = AUValue(Float(decoded) ?? 100.0)
        }
        if let decoded = UserDefaults.standard.string(forKey: "notchCeiling") {
            phaser.notchMaximumFrequency = AUValue(Float(decoded) ?? 5000.0)
        }
        if let decoded = UserDefaults.standard.string(forKey: "notchFrequency") {
            phaser.notchFrequency = AUValue(Float(decoded) ?? 1.5)
        }
        if let decoded = UserDefaults.standard.string(forKey: "phaserDepth") {
            phaser.depth = AUValue(Float(decoded) ?? 50) / 100
        }
        if let decoded = UserDefaults.standard.string(forKey: "phaserFeedback") {
            phaser.feedback = AUValue(Float(decoded) ?? 0) / 100
        }
        if let decoded = UserDefaults.standard.string(forKey: "lfoBPM") {
            phaser.lfoBPM = AUValue(Float(decoded) ?? 30.0)
        }
        
        if let decoded = UserDefaults.standard.string(forKey: "lfofrequency") {
            filter.parameter4 = AUValue(Float(decoded) ?? 1.0)
        }
        if let decoded = UserDefaults.standard.string(forKey: "lfoamplitude") {
            filter.parameter3 = AUValue(Float(decoded) ?? 1000)
        }
        if let decoded = UserDefaults.standard.string(forKey: "lfoindex") {
            filter.parameter5 = AUValue(Float(decoded) ?? 1.0)
        }
    }
    
    func updateQueue() {
        stopAll()
        phaser.stop()
        filter.stop()
        if !queue.isEmpty {
            for i in 0..<queue.count {
                let frequency = AUValue(queue[i].frequency)
                voiceArray[i].DCO1.frequency = frequency
                voiceArray[i].DCO2.frequency = frequency
                voiceArray[i].subOsc.frequency = frequency / subOctaveRatio()
                startVoice(voiceArray[i])
            }
            filter.start()
            phaser.start()
        }
            
    }
    func addDrone(_ drone: Drone) {
        queue.append(drone)
    }
    func removeDrone(_ drone: Drone) {
        if !queue.isEmpty {
            queue.remove(at: queue.firstIndex(of: drone)!)
        }
    }
    func clearQueue() {
        queue.removeAll()
    }
    
    private func startVoice(_ voice: Voice) {
        voice.DCO1.start()
        voice.DCO2.start()
        if isSub {voice.subOsc.start()}
    }
    private func stopVoice(_ voice: Voice) {
        voice.DCO1.stop()
        voice.DCO2.stop()
        voice.subOsc.stop()
    }
    private func stopAll() {
        voiceArray.forEach { stopVoice($0) }
    }

    
}
