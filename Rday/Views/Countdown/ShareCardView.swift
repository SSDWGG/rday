import SwiftUI

struct ShareCardView: View {
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
        ZStack {
            cardBackground

            VStack(spacing: 24) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(largeNumber)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .shadow(color: .black.opacity(hasPhoto ? 0.5 : 0), radius: 8)
                    Text(suffix)
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .shadow(color: .black.opacity(hasPhoto ? 0.5 : 0), radius: 8)
                }

                VStack(spacing: 12) {
                    Text(event.title)
                        .font(.system(size: 44, weight: .semibold))
                        .shadow(color: .black.opacity(hasPhoto ? 0.5 : 0), radius: 8)

                    Text(event.targetDate, style: .date)
                        .font(.system(size: 28))
                        .opacity(0.8)
                        .shadow(color: .black.opacity(hasPhoto ? 0.5 : 0), radius: 8)
                }

                Text("— Rday —")
                    .font(.system(size: 24, weight: .medium))
                    .opacity(0.6)
                    .padding(.top, 32)
            }
            .foregroundColor(.white)
            .padding(48)
        }
        .frame(width: 1080, height: 1080)
    }
}
