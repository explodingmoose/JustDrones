//
//  JustDronesApp.swift
//  JustDrones
//
//  Created by Eli Pouliot on 8/26/23.
//

import SwiftUI

@main
struct JustDronesApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


/*
Content View
 Menu Views control certain published variables (diapason, tuning normalization, and synth properties)
 Drone basis subscribes to published properties but includes the entire tonnetz's individual frequencies, note names, and pitch class integers (a tonnetz of finite size)
 Drone Layouts take the drone basis and only display relevant buttons (subscribed to drone basis)
 The drone buttons will tell the 
 Recorded Drones simply copy information from the drone
*/
