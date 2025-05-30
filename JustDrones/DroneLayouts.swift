//
//  5-limit.swift
//  JustDrones
//
//  Created by Eli Pouliot on 8/26/23.
//

import SwiftUI

struct Tonnetz: View {
    let displayMode: DisplayMode
    let synth: SynthManager
    let recorder: RecordingManager
    @ObservedObject var droneManager: DroneManager
    
    private let root3 = sqrt(3)
    private let droneRadius: CGFloat = 27.0
    //Please create function to adjust button sizes proportional to screen width!
    
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

struct CircleOfFifths: View {
    let displayMode: DisplayMode
    let synth: SynthManager
    let recorder: RecordingManager
    @ObservedObject var droneManager: DroneManager
    
    @State private var tonus: Int = 6
    
    var body: some View {
        GeometryReader { geometry in
            let circleRadius = min(geometry.size.width, geometry.size.height) * 0.4
            let midX = geometry.size.width / 2
            let midY = geometry.size.height / 2
            let angleIncrement = 2 * .pi / 12.0
        
            ForEach(12..<24, id: \.self) { F in
                let angle = (Double(F) * angleIncrement) + .pi/2.0
                let x = midX + circleRadius * cos(angle)
                let y = midY + circleRadius * sin(angle)
                
                VStack{
                    Picker("Temperament", selection: $droneManager.temperedfifth) {
                        Text("Pure").tag(Intervals.PFifth)
                        Text("Equal").tag(Intervals.ET12Fifth)
                        Text("1/4 Comma").tag(Intervals.QCFifth)
                        Text("1/3 Comma").tag(Intervals.TCFifth)
                    }
                    Picker("Tonus", selection: $tonus) {
                        ForEach(0..<12) {
                            Text(NamingHelper.noteName(fifths: 6-$0, thirds: 0)).tag($0)
                                .font(.custom("Bravura-Text", size: 17))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    .frame(width: 50.0, height: 150)
                    .pickerStyle(.wheel)
                    
                }
                .position(x: midX, y: midY)
                
                DroneButton(drone: droneManager.CoFManager[F-tonus], displayMode: displayMode, recorder: recorder, synth: synth, droneRadius: 27.0)
                    .frame(width: circleRadius * 0.2, height: circleRadius * 0.2)
                    .position(x: x, y: y)
            }
        }
        
    }
}
