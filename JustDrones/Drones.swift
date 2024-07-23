//
//  Buttons.swift
//  JustDrones
//
//  Created by Eli Pouliot on 8/26/23.
//

import Foundation
import SwiftUI

struct DroneLabel: View {
    var label: String
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(label.enumerated()), id: \.offset) { index,character in
                if character.unicodeScalars.allSatisfy({ $0.isASCII }) {
                    Text(String(character))
                        .font(.system(size: 17))
                        .foregroundColor(.black)
                } else {
                    Text(String(character))
                        .font(.custom("Bravura-Text", size: 25))
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct Drone: View {
    let noteName: String
    let pitchClass: String
    let diapason: Int
    let stop: Int
    let displayMode: DisplayMode
    let frequency: Double
    let synth: SynthManager
    let recorder: RecordingManager
    

    private let circleRadius: CGFloat = 27.0
    @State private var isTapped = false
    
    private var lowerC: Double {return Double(diapason) * 5.0/6.0}
    private var upperC: Double {return Double(diapason) * 6.0/5.0}
    
    private func normalizeOctave(input: Double, lowValue: Double, highValue: Double) -> Double {
        
        var frequency = input
        while frequency > highValue {
            frequency /= 2
        }
        while frequency < lowValue {
            frequency *= 2
        }
        return frequency
    }
    private var normfrequency: Double {
        let baseoctave = normalizeOctave(
            input: frequency,
            lowValue: lowerC,
            highValue: upperC
        )
        let octaves = -log2(Double(stop)) + 3
        let power = pow(2, abs(octaves))
        if octaves < 0 {return baseoctave / power} else {return baseoctave * power}
    }
    
    private func label() -> String {
        switch displayMode {
        case .pitchClass:
            return pitchClass
        case .frequency:
            return "\(String(format: "%.1f", normfrequency))"
        case .noteName:
            return noteName
        }
    }
    
    var body: some View {
        let circleColor = isTapped ? Color.accentColor : Color.gray
        Button(action: {
            isTapped.toggle()
            if isTapped {
                
                synth.playPitch(frequency: normfrequency)
                if recorder.recording {recorder.recorded.append(RecordedDrone(frequency: normfrequency, noteName: noteName, pitchClass: pitchClass))}
                
                if synth.frequencyinputs.count > 2 {isTapped.toggle()}
                if synth.frequencyinputs.count == 2 {
                    if synth.frequencyinputs[0] == synth.frequencyinputs[1] {
                        synth.frequencyinputs.removeFirst()
                    }
                }
                
            } else {
                if synth.frequencyinputs.count >= 1 {
                    if synth.frequencyinputs.contains(normfrequency) {
                        synth.frequencyinputs.remove(at: synth.frequencyinputs.firstIndex(of: normfrequency)!)
                    } else {
                        synth.stopPlaying1()
                        synth.stopPlaying2()
                        synth.frequencyinputs = []
                    }
                }
                
                if synth.frequencyinputs.count == 0 {
                    synth.stopPlaying1()
                }
                
                
                if synth.frequencyinputs.count < 2 {
                    synth.stopPlaying2()
                }
            }
            
            if synth.frequencyinputs.count == 0 {
                synth.stopPlaying1()
            }
        })
        {
            Circle()
                .fill(circleColor)
                .frame(width: circleRadius * 2, height: circleRadius * 2)
                .overlay(DroneLabel(label: label())
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onReceive(synth.$frequencyinputs) { updatedFrequencyInputs in
            if !updatedFrequencyInputs.contains(normfrequency) {
                isTapped = false
            }
        }
    }
}
