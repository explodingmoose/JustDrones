//
//  Buttons.swift
//  JustDrones
//
//  Created by Eli Pouliot on 8/26/23.
//

import SwiftUI

struct ButtonLabel: View {
    let displayMode: DisplayMode
    
    let frequency: Double
    let noteName: String
    let pitchClass: String
    
    var label: String {
        switch displayMode {
        case .pitchClass:
            return pitchClass
        case .frequency:
            return "\(String(format: "%.1f", frequency))"
        case .noteName:
            return noteName
        }
    }
    
    var body: some View {
        HStack(spacing: 1) {
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

struct DroneButton: View {
    let drone: Drone
    let displayMode: DisplayMode
    let namingMode: NamingMode
    let recorder: RecordingManager
    let synth: SynthManager
    
    let droneRadius: CGFloat
    @State private var isTapped = false

    var body: some View {
        let circleColor = isTapped ? Color.accentColor : Color.gray
        Button(action: {
            //Remove the drone if already on
            if isTapped && synth.queue.contains(where: { $0.id == drone.id }) {
                synth.removeDrone(drone)
                isTapped.toggle()
            } else if synth.queue.count < 4 {
                //Add the drone if off
                synth.addDrone(drone)
                isTapped.toggle()
                //Add a copy of the drone to recorded if recording
                if recorder.recording {
                    recorder.recorded.append(Drone(frequency: drone.frequency, namingIndex: drone.namingIndex, pitchClass: drone.pitchClass))
                }
            }
            
        })
        {
            Circle()
                .fill(circleColor)
                .frame(width: droneRadius * 2, height: droneRadius * 2)
                .overlay(ButtonLabel(displayMode: displayMode, frequency: drone.frequency, noteName: NamingHelper.noteName(namingIndex: drone.namingIndex, namingMode: namingMode), pitchClass: drone.pitchClass)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
