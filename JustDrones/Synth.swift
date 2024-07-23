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

enum OscillatorShapes {
    case sine
    case saw
    case square
    case triangle
}

class SynthManager: ObservableObject {
    
    var O1V1: DynamicOscillator
    var O2V1: DynamicOscillator
    var O1V2: DynamicOscillator
    var O2V2: DynamicOscillator
    
    var mixer1: Mixer
    var mixer2: Mixer
    var theMixer: DryWetMixer
    
    @Published var shapebalance: Float = 0.50 {
        didSet{
            theMixer.balance = AUValue(shapebalance)
        }
    }
    
    var LPF: LowPassFilter
    var compressor: Compressor
    var engine: AudioEngine
    
    func tableShape(shape: OscillatorShapes) -> TableType {
        switch shape {
        case .sine: return TableType.sine
        case .saw: return TableType.sawtooth
        case .square: return TableType.square
        case .triangle: return TableType.triangle
        }
  
    }
    
    @Published var FirstShape: OscillatorShapes = .sine {
        didSet {
            O1V1.setWaveform(Table(tableShape(shape: FirstShape)))
            O1V2.setWaveform(Table(tableShape(shape: FirstShape)))
        }
    }
    @Published var SecondShape: OscillatorShapes = .sine {
        didSet {
            O2V1.setWaveform(Table(tableShape(shape: SecondShape)))
            O2V2.setWaveform(Table(tableShape(shape: SecondShape)))
        }
    }

    @Published var cutoffFrequency: Float = 0.75 {
        didSet {
            LPF.cutoffFrequency = AUValue(cutoffFrequency * 2000)
        }
    }
    
    @Published var resonance: Float = 0.50 {
        didSet {
            LPF.resonance = AUValue(resonance)
        }
    }

    var Drone1 = 440.0
    var Drone2 = 440.0
    
    @Published var frequencyinputs: Array<Double> = [] {
        didSet {
            if frequencyinputs.count > 2 {
                    frequencyinputs.remove(at: 0)
                }
            if frequencyinputs.count >= 1 {
                Drone1 = frequencyinputs[0]
            }
            if frequencyinputs.count == 2 {
                Drone2 = frequencyinputs[1] }

            O1V1.frequency = AUValue(Drone1)
            O2V1.frequency = AUValue(Drone1)

            O1V2.frequency = AUValue(Drone2)
            O2V2.frequency = AUValue(Drone2)
            
            if frequencyinputs.count == 2 {
                
                O1V2.stop()
                O2V2.stop()
                O1V2.start()
                O2V2.start()
            }
        }
    }
    
    init() {
        O1V1 = DynamicOscillator(waveform: Table(.sine))
        O2V1 = DynamicOscillator(waveform: Table(.sine))
        O1V2 = DynamicOscillator(waveform: Table(.sine))
        O2V2 = DynamicOscillator(waveform: Table(.sine))
        
        mixer1 = Mixer(O1V1, O1V2)
        mixer2 = Mixer(O2V1, O2V2)
        theMixer = DryWetMixer(dry: mixer1, wet: mixer2, balance: AUValue(0.50))
        
        LPF = LowPassFilter(theMixer, cutoffFrequency: 1500.0, resonance: 0.50)
        compressor = Compressor(LPF)
        engine = AudioEngine()
        engine.output = compressor
        
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
    
    func playPitch(frequency: Double) {
        frequencyinputs.append(frequency)
        Drone1 = frequencyinputs[0]
        
        O1V1.stop()
        O1V1.start()
        O2V1.stop()
        O2V1.start()
    }
    
    func playPitch2(frequency: Double) {
        O1V2.frequency = AUValue(frequencyinputs[1])
        O1V2.frequency = AUValue(frequencyinputs[1])
        O1V2.start()
        O2V2.start()
    }
    
    func playRecordPitch(frequency: Double) {
        O1V1.frequency = AUValue(frequency)
        O2V1.frequency = AUValue(frequency)
        O1V1.stop()
        O1V1.start()
        O2V1.stop()
        O2V1.start()
    }
    
    func stopPlaying1() {
        O1V1.stop()
        O2V1.stop()
    }
    
    func stopPlaying2() {
        O1V2.stop()
        O2V2.stop()
    }
}
