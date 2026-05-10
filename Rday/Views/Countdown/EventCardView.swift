import SwiftUI

struct EventCardView: View {
    let event: CountdownEvent

    private var statusColor: Color {
        let days = event.daysFromToday
        if event.isCountdown {
            if days == 0 { return DesignSystem.Color.today }
            return days > 0 ? DesignSystem.Color.futureCountdown : DesignSystem.Color.past
        }
        return DesignSystem.Color.memorial
    }

    private var gradient: LinearGradient {
        if let index = event.cardPresetIndex,
           index >= 0,
           index < DesignSystem.Color.gradientPresets.count {
            return DesignSystem.Color.gradientPresets[index].gradient
        }
        if event.category != .none {
            let def = event.category.defaultGradient
            return LinearGradient(
                colors: [Color(hex: def.start), Color(hex: def.end)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [statusColor, statusColor.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var largeNumber: Int {
        abs(event.daysFromToday)
    }

    private var suffix: String {
        if event.isCountdown {
            let days = event.daysFromToday
            if days == 0 { return "就是今天！" }
            return days > 0 ? "天后" : "天前"
        }
        return "天"
    }

    private var hasPhoto: Bool {
        event.backgroundImageData != nil
    }

    private var backgroundImage: Image? {
        guard let data = event.backgroundImageData,
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }

    @ViewBuilder
    private var cardBackground: some View {
        if let image = backgroundImage {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: event.blurRadius)
                .overlay(Color.black.opacity(0.15))
        } else {
            gradient
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            cardBackground

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    CategoryChipView(category: event.category)
                    Spacer()
                    if event.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(largeNumber)")
                        .font(DesignSystem.Typography.cardLargeNumber)
                        .shadow(color: .black.opacity(hasPhoto ? 0.4 : 0), radius: 4)
                    Text(suffix)
                        .font(DesignSystem.Typography.cardLargeSuffix)
                        .shadow(color: .black.opacity(hasPhoto ? 0.4 : 0), radius: 4)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer()

                Text(event.title)
                    .font(DesignSystem.Typography.cardTitle)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(hasPhoto ? 0.4 : 0), radius: 4)

                Text(event.targetDate, style: .date)
                    .font(DesignSystem.Typography.cardDate)
                    .opacity(0.8)
                    .shadow(color: .black.opacity(hasPhoto ? 0.4 : 0), radius: 4)
            }
            .padding(DesignSystem.Layout.cardPadding)
            .foregroundColor(.white)
        }
        .frame(height: DesignSystem.Layout.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Layout.cardCornerRadius))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
    }
}
