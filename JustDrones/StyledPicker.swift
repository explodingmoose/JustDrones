import SwiftUI

extension HorizontalAlignment {
    enum SubCenter: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[HorizontalAlignment.center]
        }
    }
    
    static let subCentre = HorizontalAlignment(SubCenter.self)
}

public struct PickerPlus<Data, Content> : View where Data: Hashable, Content: View {
    public let sources: [Data]
    public let selection: Data
    private var cornerRadius: CGFloat?
    private var borderWidth: CGFloat?
    private var borderColor: Color?
    private var selectedTintColor: Color?
    private var backgroundColor: Color
    private let indicator: AnyView
    private let itemBuilder: (Data) -> Content
    @Environment(\.colorScheme) var colorScheme
    @State private var contentHeight: CGFloat = 0
    @State private var indicatorHeight: CGFloat = 0
    
    public init(
        _ sources: [Data],
        selection: Data,
        cornerRadius: CGFloat? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: Color? = nil,
        selectedTintColor: Color? = nil,
        backgroundColor: Color = Color.black.opacity(0.05),
        @ViewBuilder itemBuilder: @escaping (Data) -> Content
    ) {
        self.sources = sources
        self.selection = selection
        self.cornerRadius = cornerRadius
        self.selectedTintColor = selectedTintColor
        self.backgroundColor = backgroundColor
        self.itemBuilder = itemBuilder
        self.indicator =
        AnyView(
            GeometryReader { geo in
                Rectangle()
                    .foregroundColor(selectedTintColor ?? Color.white)
                    .cornerRadius(cornerRadius ?? 6.0)
                    .padding(EdgeInsets(top: borderWidth ?? 2, leading: borderWidth ?? 2, bottom: borderWidth ?? 2, trailing: borderWidth ?? 2))
                    .frame(width: geo.size.width / CGFloat(sources.count))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
                    .animation(.spring().speed(1.5), value: selection)
                    .offset(x: geo.size.width / CGFloat(sources.count) * CGFloat(sources.firstIndex(of: selection) ?? 0), y: 0)
            }.frame(height: 32)
        )
        
    }
    
    public init(
        _ sources: [Data],
        selection: Data,
        cornerRadius: CGFloat? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: Color? = nil,
        selectedTintColor: Color? = nil,
        backgroundColor: Color = Color.black.opacity(0.05),
        indicatorBuilder: @escaping () -> some View,
        @ViewBuilder itemBuilder: @escaping (Data) -> Content
    ) {
        self.sources = sources
        self.selection = selection
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.selectedTintColor = selectedTintColor
        self.backgroundColor = backgroundColor
        self.itemBuilder = itemBuilder
        self.indicator = AnyView(indicatorBuilder())
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            if(sources.contains(selection)) {
                indicator.fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 0) {
                ForEach(sources, id: \.self) { item in
                    itemBuilder(item)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6.0)
                   .fill(backgroundColor)
            )
    }
}

