//
//  Bypass.swift
//  JustDrones
//
//  Created by Eli Pouliot on 5/31/25.
//

import SwiftUI

//Buttons for bypassing
struct BypassButton: View {
    @Binding var effect: Bool
    let label: LocalizedStringResource
    
    var body: some View {
        HStack {
            Text(label)
            Button(action: {effect.toggle()}) {
                Image(systemName: "power")
                    .foregroundStyle(effect ? Color.accent : Color.gray)
            }
        }
        
    }
}
