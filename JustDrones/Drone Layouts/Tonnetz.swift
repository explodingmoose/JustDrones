//
//  Tonnetz.swift
//  JustDrones
//
//  Created by Eli Pouliot on 5/30/25.
//

import SwiftUI

struct Tonnetz: View {
    let displayMode: DisplayMode
    let synth: SynthManager
    let recorder: RecordingManager
    let droneManager: DroneManager
    
    private let root3 = sqrt(3)
    private let droneRadius: CGFloat = 27.0
    
    //Position of circle centers relative to corner to create parallelogram
    private func XPosition(F: Int, T: Int, refx: CGFloat) -> CGFloat {
        return refx + CGFloat(F)*droneRadius*2 + CGFloat(T)*droneRadius
    }
    private func YPosition(T: Int, refy: CGFloat, height: CGFloat) -> CGFloat {
        return height - (refy + CGFloat(CGFloat(T)*droneRadius*root3))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let cornerX = geometry.size.width / 2.0 - (5.0*droneRadius*2)
            let cornerY = geometry.size.height / 2.0 - (2.0*droneRadius*2)
            ForEach(0...8, id: \.self) { i in
                ForEach(0...4, id: \.self) { j in
                    DroneButton(drone: droneManager.TonnetzManager[i][j], displayMode: displayMode, recorder: recorder, synth: synth, droneRadius: droneRadius)
                        .position(x: XPosition(F: i, T: j, refx: cornerX), y: YPosition(T: j, refy: cornerY, height: height))
                }
            }
        }
    }
}
