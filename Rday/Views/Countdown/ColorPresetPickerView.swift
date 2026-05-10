import SwiftUI

struct ColorPresetPickerView: View {
    @Binding var selection: Int?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button {
                    selection = nil
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.clear)
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(selection == nil ? Color.primary : Color.clear, lineWidth: 2)
                            )

                        Image(systemName: "circle.lefthalf.filled")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                }

                ForEach(Array(DesignSystem.Color.gradientPresets.enumerated()), id: \.offset) { index, preset in
                    Button {
                        selection = index
                    } label: {
                        Circle()
                            .fill(preset.gradient)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .strokeBorder(selection == index ? Color.primary : Color.clear, lineWidth: 2)
                            )
                            .padding(4)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
