//
//  RandomMenu.swift
//  JustDrones
//
//  Created by Eli Pouliot on 6/4/25.
//

import SwiftUI

struct RandomMenu: View {
    @Binding var isRandomMenuOn: Bool
    
    @State private var note = "Go"
    private let notes = ["A", "A\u{266F}/B\u{266D}", "B", "C", "C\u{266F}/D\u{266D}", "D", "D\u{266F}/E\u{266D}", "E", "F", "F\u{266F}/G\u{266D}", "G", "G\u{266F}/A\u{266D}"]
    
    var body: some View {
        VStack {
            Text("A random note:")
                .padding()
            Button(action: {note = notes.randomElement()!}, label: {
                Circle()
                    .fill(.gray)
                    .frame(width: 54.0)
                    .overlay(Text(note).foregroundStyle(.black))
            })
            
            Button(action: {
                isRandomMenuOn.toggle()
            }) {
                Text("Close")
                    .foregroundStyle(.blue)
            }
            .padding()
        }
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
}
