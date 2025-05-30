//
//  Drone basis.swift
//  JustDrones
//
//  Created by Eli Pouliot on 1/2/25.
//

import SwiftUI


//Notename function
struct NamingHelper {
    public static let naturalNotes = ["F", "C", "G", "D", "A", "E", "B"]
    public static func noteName(fifths: Int, thirds: Int) -> String {
            let totalindex = fifths + 4 + (4 * thirds)
            var postotalindex = totalindex
            while postotalindex < 0 {postotalindex += 7}
            let fifthnameindex = postotalindex % 7
            let accidentalindex = Int(floor(Double(totalindex)/7.0))
            var Notename = naturalNotes[fifthnameindex]
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
    public static func pitchClass(fifths: Int, thirds: Int) -> String {
        var total = 9 + 7*fifths + 4*thirds
        while total < 0 {total += 12}
        return String(total % 12)
    }
}

//Interval constants
struct Intervals {
    public static let PFifth = 3.0/2.0
    public static let QCFifth = pow(5, 0.25) //quarter comma
    public static let TCFifth = pow(10.0/3.0, 1.0/3.0) //third comma
    public static let ET12Fifth = pow(2.0, 7.0/12.0) //Equal Tempered
}

class Drone: Identifiable, Equatable, Codable {
    static func == (lhs: Drone, rhs: Drone) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: UUID
    var frequency:Double
    let noteName:String
    let pitchClass:String
    
    var isDroneOn: Bool = false
    
    init(id: UUID = UUID(), frequency: Double, noteName: String, pitchClass: String) {
        self.id = id
        self.frequency = frequency
        self.noteName = noteName
        self.pitchClass = pitchClass
    }
}

//Handles creation and tuning of drones, tuning parameters
class DroneManager: ObservableObject {
    private func frequency(temper: Double, fifths: Int, thirds: Int, diapason: Int) -> Double {
        let diapason = Double(diapason)
        let fifthpower = pow(temper, abs(Double(fifths)))
        let thirdpower = pow(1.25, abs(Double(thirds)))
        var frequency = diapason
        if fifths < 0 {frequency /= fifthpower} else {frequency *= fifthpower}
        if thirds < 0 {frequency /= thirdpower} else {frequency *= thirdpower}
        return frequency
    }
    
    private func updateTonnetz() {
        for i in 0...8 {
            for j in 0...4 {
                let fifths = i-4
                let thirds = j-2
                let frequency = frequency(temper: Intervals.PFifth, fifths: fifths, thirds: thirds, diapason: diapason)
                TonnetzManager[i][j].frequency = normfrequency(frequency: frequency, diapason: diapason, stop: stop)
            }
        }
    }
    private func updateCoF() {
        for i in 0...23 {
            let fifths = i - 12
            let frequency = frequency(temper: temperedfifth, fifths: fifths, thirds: 0, diapason: diapason)
            CoFManager[i].frequency = normfrequency(frequency: frequency, diapason: diapason, stop: stop)
        }
    }
    
    //When these variables are updated, update the Tonnetz and CoF, then save the value
    @Published var diapason: Int = 440 {
        didSet{
            updateTonnetz()
            updateCoF()
            UserDefaults.standard.set(String(diapason), forKey: "diapason")
        }
    }
    @Published var stop: Int = 16 {
        didSet{
            updateTonnetz()
            updateCoF()
            UserDefaults.standard.set(String(stop), forKey: "stop")
        }
    }
    @Published var temperedfifth: Double = 1.5 {
        didSet{
            updateCoF()
            UserDefaults.standard.set(String(temperedfifth), forKey: "temperedfifth")
        }
    }
    
    // A function to keep pitches within the ranges of the stop
    private func normfrequency(frequency: Double, diapason: Int, stop: Int) -> Double {
        
        let lowerC = Double(diapason) * 5.0/6.0
        let upperC = Double(diapason) * 6.0/5.0
        
        var baseoctave = frequency

        while baseoctave > upperC {
            baseoctave /= 2
        }
        while baseoctave < lowerC {
            baseoctave *= 2
        }
   
        let octaves = -log2(Double(stop)) + 3
        let power = pow(2, abs(octaves))
        if octaves < 0 {return baseoctave / power} else {return baseoctave * power}
        
    }
    
    //Set up a matrix of the proper size
    private static func newTonnetzMatrix() -> [[Drone]] {
        var matrix: [[Drone]] = []

        for i in 0...8 {
            matrix.append( [] )

            for j in 0...4 {
                let fifths = i-4
                let thirds = j-2
                matrix[i].append( Drone(frequency: 0, noteName: NamingHelper.noteName(fifths: fifths, thirds: thirds), pitchClass: NamingHelper.pitchClass(fifths: fifths, thirds: thirds)))
            }
        }

        return matrix
    }
    private static func newCoFMatrix() -> [Drone] {
        var matrix: [Drone] = []
        
        for i in 0...23 {
            let fifths = i - 12
            matrix.append(Drone(frequency: 0, noteName: NamingHelper.noteName(fifths: fifths, thirds: 0), pitchClass: NamingHelper.pitchClass(fifths: fifths, thirds: 0)))
        }
        
        return matrix
    }
    
    @Published var TonnetzManager: [[Drone]] = []
    @Published var CoFManager: [Drone] = []

    init() {
        //Creaate Tonnetz and CoF
        TonnetzManager = DroneManager.newTonnetzMatrix()
        CoFManager = DroneManager.newCoFMatrix()
        
        //Recall stored parameters
        if let decoded = UserDefaults.standard.string(forKey: "diapason") {
            diapason = Int(decoded) ?? 440
        }
        if let decoded = UserDefaults.standard.string(forKey: "stop") {
            stop = Int(decoded) ?? 16
        }
        if let decoded = UserDefaults.standard.string(forKey: "temperedfifth") {
            temperedfifth = Double(decoded) ?? 1.5
        }
        
        //Tune Tonnetz
        for i in 0...8 {
            for j in 0...4 {
                let fifths = i-4
                let thirds = j-2
                let frequency = frequency(temper: Intervals.PFifth, fifths: fifths, thirds: thirds, diapason: diapason)
                TonnetzManager[i][j].frequency = normfrequency(frequency: frequency, diapason: diapason, stop: stop)
            }
        }
        //Tune CoF
        for i in 0...23 {
            let fifths = i - 12
            let frequency = frequency(temper: temperedfifth, fifths: fifths, thirds: 0, diapason: diapason)
            CoFManager[i].frequency = normfrequency(frequency: frequency, diapason: diapason, stop: stop)
        }
    }
}
