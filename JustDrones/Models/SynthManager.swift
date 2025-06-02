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
        voiceMixer = DryWetMixer(dry: DCO1, wet: DCO2)
    }
}

//The Synth Manager behaves as the Conductor
@Observable class SynthManager {
    
    @ObservationIgnored var voice1 = Voice()
    @ObservationIgnored var voice2 = Voice()
    @ObservationIgnored var voice3 = Voice()
    @ObservationIgnored var voice4 = Voice()
    @ObservationIgnored var voiceArray: [Voice]
    
    @ObservationIgnored var engine: AudioEngine!
    @ObservationIgnored var voiceMixer: Mixer!
    @ObservationIgnored var subMixer: Mixer!
    
    @ObservationIgnored var filter: OperationEffect!
    @ObservationIgnored var phaser: Phaser!
    @ObservationIgnored var compressor: Compressor!
    
    //Drones that are on
    var queue: [Drone] {
        didSet {
            updateQueue()
        }
    }
    
    //Bypass Parameters
    var isPhaser: Bool = false {
        didSet {
            updateQueue()
            UserDefaults.standard.set(isPhaser, forKey: "synth.isPhaser")
        }
    }
    var isFilter: Bool = true {
        didSet {
            updateQueue()
            UserDefaults.standard.set(isFilter, forKey: "synth.isFilter")
        }
    }
    var isLFO: Bool = true {
        didSet {
            filter.parameter6 = isLFO.toAUValue()
            updateQueue()
            UserDefaults.standard.set(isLFO, forKey: "synth.isLFO")
        }
    }
    var isSub: Bool = true {
        didSet {
            if isSub {voiceMixer.addInput(subMixer)} else {voiceMixer.removeInput(subMixer)}
            updateQueue()
            UserDefaults.standard.set(isSub, forKey: "synth.isSub")
        }
    }
    
    //Oscillator Parameters
    var shapeBalance: AUValue {
        didSet{
            voiceArray.forEach { voice in
                voice.voiceMixer.balance = shapeBalance
            }
            UserDefaults.standard.set(shapeBalance, forKey: "synth.shapeBalance")
        }
    }
    var O1Morph: AUValue {
        didSet {
            voiceArray.forEach { voice in
                voice.DCO1.index = O1Morph
            }
            UserDefaults.standard.set(O1Morph, forKey: "synth.O1Morph")
        }
    }
    var O2Morph: AUValue {
        didSet {
            voiceArray.forEach { voice in
                voice.DCO2.index = O2Morph
            }
            UserDefaults.standard.set(String(O2Morph), forKey: "synth.O2Morph")
        }
    }
    
    //SubOsc Parameters
    var subOctave: SubOctave! {
        didSet {
            updateQueue()
            UserDefaults.standard.set(subOctave.rawValue, forKey: "synth.subOctave")
        }
    }
    //TODO: Add controls for square wave, balance
    
    //Filter Parameters
    var cutoffFrequency: AUValue {
        //this variable is saved at 1/2000 times the actual cutoff
        didSet {
            filter.parameter1 = cutoffFrequency * 2000.0
            UserDefaults.standard.set(cutoffFrequency, forKey: "synth.cutoff")
        }
    }
    var resonance: AUValue {
        //in dB
        didSet {
            filter.parameter2 = resonance
            UserDefaults.standard.set(resonance, forKey: "synth.resonance")
        }
    }
    
    //Phaser Parameters
    var notchFloor: AUValue {
        didSet {
            //20 - 5000Hz
            phaser.notchMinimumFrequency = notchFloor
            UserDefaults.standard.set(notchFloor, forKey: "synth.notchFloor")
        }
    }
    var notchCeiling: AUValue {
        didSet {
            //20 - 10000Hz
            phaser.notchMaximumFrequency = notchCeiling
            UserDefaults.standard.set(notchCeiling, forKey: "synth.notchCeiling")
        }
    }
    var notchFrequency: AUValue {
        didSet {
            //1.1-4Hz
            phaser.notchFrequency = notchFrequency
            UserDefaults.standard.set(notchFrequency, forKey: "synth.notchFrequency")
        }
    }
    var phaserDepth: AUValue {
        didSet {
            //0-100%
            phaser.depth = phaserDepth/100
            UserDefaults.standard.set(phaserDepth, forKey: "synth.phaserDepth")
        }
    }
    var phaserFeedback: AUValue {
        didSet {
            phaser.feedback = phaserFeedback/100
            UserDefaults.standard.set(phaserFeedback, forKey: "synth.phaserFeedback")
        }
    }
    var lfoBPM: AUValue {
        didSet {
            //24 - 360 BPM
            phaser.lfoBPM = lfoBPM
            UserDefaults.standard.set(lfoBPM, forKey: "synth.lfoBPM")
        }
    }
    
    //LFO Parameters
    var lfoFrequency: AUValue {
        didSet {
            filter.parameter4 = lfoFrequency
            UserDefaults.standard.set(lfoFrequency, forKey: "synth.lfoFrequency")
        }
    }
    var lfoDepth: AUValue {
        didSet {
            //in hz (applies to cutoff Frequency)
            filter.parameter3 = lfoDepth
            UserDefaults.standard.set(lfoDepth, forKey: "synth.lfoDepth")
        }
    }
    var lfoIndex: AUValue {
        didSet {
            filter.parameter5 = lfoIndex
            UserDefaults.standard.set(lfoIndex, forKey: "synth.lfoIndex")
        }
    }
    
    //Master
    var compressorGain: AUValue {
        didSet {
            compressor.masterGain = compressorGain
            UserDefaults.standard.set(compressorGain, forKey: "synth.compressorGain")
        }
    }
    
    init() {
        
        queue = []
        voiceArray = [voice1, voice2, voice3, voice4]
        
        //Set up parameters (defaults are registered in App Delegate)
        //Bypass Parameters
        isPhaser = UserDefaults.standard.bool(forKey: "synth.isPhaser")
        isFilter = UserDefaults.standard.bool(forKey: "synth.isFilter")
        isLFO = UserDefaults.standard.bool(forKey: "synth.isLFO")
        isSub = UserDefaults.standard.bool(forKey: "synth.isSub")
        
        //Main Oscillators
        shapeBalance = UserDefaults.standard.float(forKey: "synth.shapeBalance")
        O1Morph = UserDefaults.standard.float(forKey: "synth.O1Morph")
        O2Morph = UserDefaults.standard.float(forKey: "synth.O2Morph")
        //Sub
        let decoded = UserDefaults.standard.float(forKey: "synth.subOctave")
        subOctave = SubOctave(rawValue: decoded) ?? .Ottava
        //Filter
        cutoffFrequency = UserDefaults.standard.float(forKey: "synth.cutoffFrequency")
        resonance = UserDefaults.standard.float(forKey: "synth.resonance")
        //LFO
        lfoFrequency = UserDefaults.standard.float(forKey: "synth.lfoFrequency")
        lfoDepth = UserDefaults.standard.float(forKey: "synth.lfoDepth")
        lfoIndex = UserDefaults.standard.float(forKey: "synth.lfoIndex")
        //Phaser
        notchFloor = UserDefaults.standard.float(forKey: "synth.notchFloor")
        notchCeiling = UserDefaults.standard.float(forKey: "synth.notchCeiling")
        notchFrequency = UserDefaults.standard.float(forKey: "synth.notchFrequency")
        phaserDepth = UserDefaults.standard.float(forKey: "synth.phaserDepth")
        phaserFeedback = UserDefaults.standard.float(forKey: "synth.phaserFeedback")
        lfoBPM = UserDefaults.standard.float(forKey: "synth.lfoBPM")
        //Compressor
        compressorGain = UserDefaults.standard.float(forKey: "synth.compressorGain")
        
        //Set up nodes
        engine = AudioEngine()
        
        //Generators
        voiceMixer = Mixer(voice1.voiceMixer, voice2.voiceMixer, voice3.voiceMixer, voice4.voiceMixer)
        voiceArray.forEach { voice in
            voice.DCO1.index = O1Morph
            voice.DCO2.index = O2Morph
            voice.voiceMixer.balance = shapeBalance
        }
        subMixer = Mixer(voice1.subOsc, voice2.subOsc, voice3.subOsc, voice4.subOsc)
        
        //Effects
        phaser = Phaser(voiceMixer, notchMinimumFrequency: notchFloor, notchMaximumFrequency: notchCeiling, notchFrequency: notchFrequency, depth: phaserDepth, feedback: phaserFeedback, lfoBPM: lfoBPM)
        phaser.stop()
        
        //filter with LFO on cutoff
        filter = OperationEffect(phaser) { input, parameters in
            
            let cutoff = parameters[0]
            let rez = parameters[1]
            let oscAmp = parameters[2]
            let oscRate = parameters[3]
            let oscIndex = parameters[4]
            let lfoBypass = parameters[5]
            
            let lfo = Operation.morphingOscillator(frequency: oscRate,
                                                   amplitude: oscAmp,
                                                   index: oscIndex)
            if !isFilter {return input}
            return input.moogLadderFilter(cutoffFrequency: max((lfo * lfoBypass) + cutoff, 0),
                                          resonance: rez)
        }
        filter.parameter1 = cutoffFrequency * 2000.0
        filter.parameter2 = resonance
        filter.parameter3 = lfoDepth
        filter.parameter4 = lfoFrequency
        filter.parameter5 = lfoIndex
        filter.parameter6 = isLFO.toAUValue()
        filter.stop()
        
        compressor = Compressor(filter, masterGain: compressorGain)
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
                voiceArray[i].subOsc.frequency = frequency * subOctave.rawValue
                startVoice(voiceArray[i])
            }
            if isFilter {filter.start()}
            if isPhaser {phaser.start()}
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
