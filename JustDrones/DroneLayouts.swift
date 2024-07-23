//
//  5-limit.swift
//  JustDrones
//
//  Created by Eli Pouliot on 8/26/23.
//

import Foundation
import SwiftUI

let gamut = ["F", "C", "G", "D", "A", "E", "B"]

let PFifth = 3.0/2.0
let QCFifth = pow(5, 0.25) //quarter comma
let TCFifth = pow(10.0/3.0, 1.0/3.0) //third comma
let ET12Fifth = pow(2.0, 7.0/12.0) //Equal Tempered

func frequency(temper: Double, fifths: Int, thirds: Int, diapason: Double) -> Double {
    let fifthpower = pow(temper, abs(Double(fifths)))
    let thirdpower = pow(1.25, abs(Double(thirds)))
    var frequency = diapason
    if fifths < 0 {frequency /= fifthpower} else {frequency *= fifthpower}
    if thirds < 0 {frequency /= thirdpower} else {frequency *= thirdpower}
    return frequency
}

func pitchClass(fifths: Int, thirds: Int) -> String {
    var total = 9 + 7*fifths + 4*thirds
    while total < 0 {total += 12}
    return String(total % 12)
}

func noteName(fifths: Int, thirds: Int) -> String {
    let totalindex = fifths + 4 + (4 * thirds)
    var postotalindex = totalindex
    while postotalindex < 0 {postotalindex += 7}
    let fifthnameindex = postotalindex % 7
    let accidentalindex = Int(floor(Double(totalindex)/7.0))
    var Notename = gamut[fifthnameindex]
    if accidentalindex == 1 {Notename.append("\u{E262}")}
    if accidentalindex == -1 {Notename.append("\u{E260}")}
    if accidentalindex == 2 {Notename.append("\u{E263}")}
    if accidentalindex == -2 {Notename.append("\u{E264}")}
    if accidentalindex == 3 {Notename.append("\u{E265}")}
    if accidentalindex == -3 {Notename.append("\u{E266}")}
    if accidentalindex > 3 {Notename.append("+")}
    if accidentalindex < -3 {Notename.append("-")}
    return Notename
}


struct Tonnetz: View {
    let diapason: Int
    let stop: Int
    let displayMode: DisplayMode
    let synth: SynthManager
    let recorder: RecordingManager
    
    private let root3 = sqrt(3)
    private let droneradius = 27.0
    
    private func maxbuttons(ref: CGFloat) -> Range<Int> {
        let length = ref - 27.0
        let d = 27.0 * 2.0
        let totalbuttons = length / d
        let floor = floorf(Float(totalbuttons))
        return -Int(floor)..<(Int(floor) + 1)
    }
    
    private func XPosition(F: Int, T: Int, refx: CGFloat) -> CGFloat {
        return refx + CGFloat(F*54) + CGFloat(T*27)
    }
    
    private func YPosition(T: Int, refy: CGFloat, height: CGFloat) -> CGFloat {
        return height - (refy + CGFloat(Double(T)*droneradius*root3))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let midX = geometry.size.width / 2.0
            let midY = geometry.size.height / 2.0
            let pHeight = height / CGFloat(root3) //height of parallelogram
            let FRange = maxbuttons(ref: (width - pHeight)/2) //max amount of fifths
            let TRange = maxbuttons(ref: midY) //max amount of thirds
            ForEach(TRange, id:\.self) { T in
                ForEach(FRange, id:\.self) {F in
                    Drone(noteName: noteName(fifths: F, thirds: T), pitchClass: pitchClass(fifths: F, thirds: T), diapason: diapason, stop: stop, displayMode: displayMode, frequency: frequency(temper: PFifth, fifths: F, thirds: T, diapason: Double(diapason)), synth: synth, recorder: recorder)
                        .position(x: XPosition(F: F, T: T, refx: midX), y: YPosition(T: T, refy: midY, height: height))
                }
            }
        }
    }
}

struct CircleOfFifths: View {
    let diapason: Int
    let stop: Int
    let displayMode: DisplayMode
    let synth: SynthManager
    let recorder: RecordingManager
    
    @State private var temper = PFifth
    @State private var tonus: Int = 6
    
    var body: some View {
        GeometryReader { geometry in
            let circleRadius = min(geometry.size.width, geometry.size.height) * 0.4
            let midX = geometry.size.width / 2
            let midY = geometry.size.height / 2
            let angleIncrement = 2 * .pi / 12.0
            
            ForEach(0..<12, id: \.self) { col in
                let angle = (Double(col) * angleIncrement)
                let x = midX + circleRadius * cos(angle)
                let y = midY + circleRadius * sin(angle)
                
                VStack{
                    Picker("Temperament", selection: $temper) {
                        Text("Pure").tag(PFifth)
                        Text("Equal").tag(ET12Fifth)
                        Text("1/4 Comma").tag(QCFifth)
                        Text("1/3 Comma").tag(TCFifth)
                    }
                    
                    Picker("Tonus", selection: $tonus) {
                        ForEach(1..<13) {
                            Text(noteName(fifths: 6-$0, thirds: 0)).tag($0)
                                .font(.custom("Bravura-Text", size: 17))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 50.0, height: 150)
                    .pickerStyle(.wheel)
                }
                .position(x: midX, y: midY)
                Drone(noteName: noteName(fifths: col - tonus, thirds: 0), pitchClass: pitchClass(fifths: col - tonus, thirds: 0), diapason: diapason, stop: stop, displayMode: displayMode, frequency: frequency(temper: temper, fifths: col - tonus, thirds: 0, diapason: Double(diapason)), synth: synth, recorder: recorder)
                    .frame(width: circleRadius * 0.2, height: circleRadius * 0.2)
                    .position(x: x, y: y)
            }
        }
    }
}
