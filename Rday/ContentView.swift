import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppStateManager.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            CountdownListView()
                .tabItem {
                    Label(Constants.countdownTabTitle, systemImage: Constants.countdownTabIcon)
                }

            TodoListView()
                .tabItem {
                    Label(Constants.todoTabTitle, systemImage: Constants.todoTabIcon)
                }

            MarqueeToolView()
                .tabItem {
                    Label(Constants.marqueeTabTitle, systemImage: Constants.marqueeTabIcon)
                }
        }
        .onAppear {
            NotificationService.shared.onNavigateToTodo = { todoId in
                appState.pendingEmailTodoId = todoId
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                appState.handleDidBecomeActive(modelContext: modelContext)
            }
        }
    }
}

private struct MarqueeToolView: View {
    @AppStorage("marquee.message") private var message: String = "生日快乐，祝你天天开心"
    @AppStorage("marquee.fontSize") private var fontSize: Double = 88
    @AppStorage("marquee.speed") private var speed: Double = 120
    @AppStorage("marquee.textColorHex") private var textColorHex: String = "FFFFFF"
    @AppStorage("marquee.backgroundColorHex") private var backgroundColorHex: String = "000000"
    @AppStorage("marquee.fontStyle") private var fontStyleRawValue: String = MarqueeFontStyle.rounded.rawValue
    @AppStorage("marquee.playbackOrientation") private var playbackOrientationRawValue: String = MarqueePlaybackOrientation.landscape.rawValue

    @State private var isPresentingPlayback: Bool = false

    private var trimmedMessage: String {
        message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canPlay: Bool {
        !trimmedMessage.isEmpty
    }

    private var colorsAreDistinct: Bool {
        normalizedHex(textColorHex) != normalizedHex(backgroundColorHex)
    }

    private var fontStyle: MarqueeFontStyle {
        MarqueeFontStyle(rawValue: fontStyleRawValue) ?? .rounded
    }

    private var playbackOrientation: MarqueePlaybackOrientation {
        MarqueePlaybackOrientation(rawValue: playbackOrientationRawValue) ?? .landscape
    }

    private var textColorBinding: Binding<Color> {
        Binding(
            get: { Color(hex: textColorHex) },
            set: { newColor in
                textColorHex = newColor.hexString() ?? "FFFFFF"
                enforceDistinctColors(changed: .text)
            }
        )
    }

    private var backgroundColorBinding: Binding<Color> {
        Binding(
            get: { Color(hex: backgroundColorHex) },
            set: { newColor in
                backgroundColorHex = newColor.hexString() ?? "000000"
                enforceDistinctColors(changed: .background)
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("文字") {
                    TextField("输入一句话", text: $message, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("字体大小")
                            Spacer()
                            Text("\(Int(fontSize))")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $fontSize, in: 36...180, step: 2)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("滚动速度")
                            Spacer()
                            Text("\(Int(speed)) pt/s")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $speed, in: 40...260, step: 5)
                    }

                    Picker("字体样式", selection: $fontStyleRawValue) {
                        ForEach(MarqueeFontStyle.allCases) { style in
                            Text(style.title).tag(style.rawValue)
                        }
                    }

                    Picker("播放方向", selection: $playbackOrientationRawValue) {
                        ForEach(MarqueePlaybackOrientation.allCases) { orientation in
                            Text(orientation.title).tag(orientation.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    ColorPicker("字体颜色", selection: textColorBinding, supportsOpacity: false)
                    ColorPicker("背景颜色", selection: backgroundColorBinding, supportsOpacity: false)
                } header: {
                    Text("样式")
                }
                footer: {
                    Text("文字颜色和背景颜色不能相同，选到同色时会自动调整另一项为对比色。")
                }

                Section("预览") {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(hex: backgroundColorHex))

                        if canPlay {
                            MarqueeScrollingText(
                                text: trimmedMessage,
                                fontSize: min(CGFloat(fontSize), 64),
                                textColor: Color(hex: textColorHex),
                                speed: CGFloat(speed),
                                fontStyle: fontStyle
                            )
                            .frame(height: 120)
                        } else {
                            Text("先输入一句话")
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .frame(height: 120)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }

                Section {
                    Button {
                        isPresentingPlayback = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("全屏播放", systemImage: "play.fill")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(!canPlay)
                }
            }
            .navigationTitle(Constants.marqueeTabTitle)
            .onAppear {
                if !colorsAreDistinct {
                    enforceDistinctColors(changed: .background)
                }
            }
        }
        .fullScreenCover(isPresented: $isPresentingPlayback) {
            MarqueePlaybackView(
                text: trimmedMessage,
                fontSize: CGFloat(fontSize),
                speed: CGFloat(speed),
                textColor: Color(hex: textColorHex),
                backgroundColor: Color(hex: backgroundColorHex),
                fontStyle: fontStyle,
                playbackOrientation: playbackOrientation
            )
        }
    }

    private func normalizedHex(_ hex: String) -> String {
        hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).uppercased()
    }

    private func enforceDistinctColors(changed: ChangedColor) {
        guard normalizedHex(textColorHex) == normalizedHex(backgroundColorHex) else {
            return
        }

        switch changed {
        case .text:
            backgroundColorHex = Color(hex: textColorHex).contrastingHexString()
        case .background:
            textColorHex = Color(hex: backgroundColorHex).contrastingHexString()
        }
    }

    private enum ChangedColor {
        case text
        case background
    }
}

private struct MarqueePlaybackView: View {
    @Environment(\.dismiss) private var dismiss

    let text: String
    let fontSize: CGFloat
    let speed: CGFloat
    let textColor: Color
    let backgroundColor: Color
    let fontStyle: MarqueeFontStyle
    let playbackOrientation: MarqueePlaybackOrientation

    @State private var showsControls: Bool = true

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            MarqueeScrollingText(
                text: text,
                fontSize: fontSize,
                textColor: textColor,
                speed: speed,
                fontStyle: fontStyle
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showsControls.toggle()
                }
            }

            if showsControls {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(textColor.opacity(0.92))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Spacer()

                    Text("轻点屏幕可隐藏或显示控制按钮")
                        .font(.footnote)
                        .foregroundStyle(textColor.opacity(0.75))
                        .padding(.bottom, 28)
                }
                .transition(.opacity)
            }
        }
        .statusBarHidden()
        .onAppear {
            AppOrientationController.apply(playbackOrientation.interfaceMask)
        }
        .onDisappear {
            AppOrientationController.reset()
        }
    }
}

private struct MarqueeScrollingText: View {
    let text: String
    let fontSize: CGFloat
    let textColor: Color
    let speed: CGFloat
    let fontStyle: MarqueeFontStyle

    @State private var textWidth: CGFloat = 0
    @State private var startDate: Date = .now

    var body: some View {
        GeometryReader { proxy in
            let containerWidth = proxy.size.width

            ZStack(alignment: .leading) {
                Text(text)
                    .font(fontStyle.font(size: fontSize))
                    .lineLimit(1)
                    .fixedSize()
                    .hidden()
                    .background {
                        GeometryReader { textProxy in
                            Color.clear
                                .preference(key: TextWidthPreferenceKey.self, value: textProxy.size.width)
                        }
                    }

                TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: text.isEmpty || textWidth == 0)) { context in
                    let distance = max(textWidth + containerWidth, 1)
                    let elapsed = max(context.date.timeIntervalSince(startDate), 0)
                    let traveled = (CGFloat(elapsed) * speed).truncatingRemainder(dividingBy: distance)

                    Text(text)
                        .font(fontStyle.font(size: fontSize))
                        .foregroundStyle(textColor)
                        .lineLimit(1)
                        .fixedSize()
                        .offset(x: containerWidth - traveled)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .clipped()
            .onAppear {
                startDate = .now
            }
            .onChange(of: text) { _, _ in
                startDate = .now
            }
            .onChange(of: fontSize) { _, _ in
                startDate = .now
            }
            .onChange(of: speed) { _, _ in
                startDate = .now
            }
            .onPreferenceChange(TextWidthPreferenceKey.self) { width in
                guard width > 0, abs(width - textWidth) > 1 else { return }
                textWidth = width
                startDate = .now
            }
        }
    }
}

private enum MarqueeFontStyle: String, CaseIterable, Identifiable {
    case `default`
    case rounded
    case serif
    case monospaced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .default:
            return "默认"
        case .rounded:
            return "圆角"
        case .serif:
            return "衬线"
        case .monospaced:
            return "等宽"
        }
    }

    var design: Font.Design {
        switch self {
        case .default: .default
        case .rounded: .rounded
        case .serif: .serif
        case .monospaced: .monospaced
        }
    }

    func font(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: design)
    }
}

private enum MarqueePlaybackOrientation: String, CaseIterable, Identifiable {
    case portrait
    case landscape

    var id: String { rawValue }

    var title: String {
        switch self {
        case .portrait:
            return "竖屏"
        case .landscape:
            return "横屏"
        }
    }

    var interfaceMask: UIInterfaceOrientationMask {
        switch self {
        case .portrait: .portrait
        case .landscape: .landscape
        }
    }
}

private struct TextWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
