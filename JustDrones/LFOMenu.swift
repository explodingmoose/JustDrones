struct LFOMenu: View {
    @Binding var isLFOMenuOpen: Bool
    @ObservedObject var synth: SynthManager
    
    var body: some View {
        VStack {
            Text("LFO (Filter Cutoff)")
            Divider()
            HStack{
                VStack{
                    VStack {
                        Text("Rate: \(String(format: "%.2f", synth.lfofrequency)) Hz")
                        Slider(value: $synth.lfofrequency, in: 0...20)
                    }
                    VStack {
                        Text("Depth: \(String(format: "%.2f", synth.lfoamplitude)) Hz")
                        Slider(value: $synth.lfoamplitude, in: 0...2000)
                    }
                }
                VStack {
                    Text("Shape:")
                    HStack {
                        Image("Sine")
                            .font(.system(size: 24))
                            .foregroundColor(.accent)
                            .onTapGesture{synth.lfoindex = 0}
                        Image("Square")
                            .font(.system(size: 24))
                            .foregroundColor(.accent)
                            .onTapGesture{synth.lfoindex = 1}
                        Image("Sawtooth")
                            .font(.system(size: 24))
                            .foregroundColor(.accent)
                            .onTapGesture{synth.lfoindex = 2}
                        Image("Reverse Sawtooth")
                            .font(.system(size: 24))
                            .foregroundColor(.accent)
                            .onTapGesture{synth.lfoindex = 3}
                    }
                    SmallKnob(value: $synth.lfoindex, range: 0...3)
                        .frame(width: 50, height: 50)
                    Text("Morph: \(String(format: "%.2f", synth.lfoindex/3))")
                }
            }
            Button(action: {
                isLFOMenuOpen.toggle()
            }) {
                Text("Close")
                    .foregroundColor(.blue)
            }
            .padding()

        }
        .padding()
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .zIndex(3)
    }
}