import SwiftUI
import SwiftData
import PhotosUI

struct CountdownFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let event: CountdownEvent?

    @State private var title: String = ""
    @State private var targetDate: Date = Date()
    @State private var isCountdown: Bool = true
    @State private var note: String = ""
    @State private var category: EventCategory = .none
    @State private var isPinned: Bool = false
    @State private var cardPresetIndex: Int? = nil
    @State private var showDeleteConfirmation: Bool = false

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var backgroundImageData: Data?
    @State private var blurRadius: Double = 0
    @State private var hasPhoto: Bool = false

    private var isEditing: Bool { event != nil }
    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    init(event: CountdownEvent? = nil) {
        self.event = event
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("标题", text: $title)

                    Picker("类型", selection: $isCountdown) {
                        Text("倒数日").tag(true)
                        Text("纪念日").tag(false)
                    }
                    .pickerStyle(.segmented)

                    DatePicker("日期", selection: $targetDate, displayedComponents: .date)
                }

                Section("分类") {
                    CategoryPickerView(selection: $category)
                }

                Section("外观") {
                    ColorPresetPickerView(selection: $cardPresetIndex)
                }

                Section("背景图片") {
                    HStack {
                        Text("选择照片")
                        Spacer()
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label(hasPhoto ? "更换" : "选取", systemImage: "photo")
                        }
                        .onChange(of: selectedPhotoItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    backgroundImageData = data
                                    hasPhoto = true
                                }
                            }
                        }

                        if hasPhoto {
                            Button {
                                selectedPhotoItem = nil
                                backgroundImageData = nil
                                hasPhoto = false
                                blurRadius = 0
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    if let data = backgroundImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .blur(radius: blurRadius)
                            .overlay(alignment: .center) {
                                Text("\(Int(blurRadius))% 模糊")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.black.opacity(0.5))
                                    .clipShape(Capsule())
                            }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("背景模糊")
                                Spacer()
                                Text("\(Int(blurRadius))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $blurRadius, in: 0...20, step: 1)
                        }
                    }
                }

                Section {
                    Toggle("置顶", isOn: $isPinned)
                }

                Section("备注（可选）") {
                    TextField("添加备注...", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                if isEditing {
                    Section {
                        Button("删除事件", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑倒数日" : "新建倒数日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let event {
                    title = event.title
                    targetDate = event.targetDate
                    isCountdown = event.isCountdown
                    note = event.note ?? ""
                    category = event.category
                    isPinned = event.isPinned
                    cardPresetIndex = event.cardPresetIndex
                    backgroundImageData = event.backgroundImageData
                    blurRadius = event.blurRadius
                    hasPhoto = event.backgroundImageData != nil
                }
            }
            .confirmationDialog("确定删除此事件吗？", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("删除", role: .destructive) {
                    delete()
                    dismiss()
                }
                Button("取消", role: .cancel) {}
            }
        }
    }

    private func save() {
        guard canSave else { return }

        if let existing = event {
            existing.title = title.trimmingCharacters(in: .whitespaces)
            existing.targetDate = targetDate
            existing.isCountdown = isCountdown
            existing.note = note.isEmpty ? nil : note
            existing.category = category
            existing.isPinned = isPinned
            existing.cardPresetIndex = cardPresetIndex
            existing.backgroundImageData = backgroundImageData
            existing.blurRadius = blurRadius
        } else {
            let event = CountdownEvent(
                title: title.trimmingCharacters(in: .whitespaces),
                targetDate: targetDate,
                isCountdown: isCountdown,
                note: note.isEmpty ? nil : note,
                categoryRaw: category.rawValue,
                isPinned: isPinned,
                cardPresetIndex: cardPresetIndex,
                backgroundImageData: backgroundImageData,
                blurRadius: blurRadius
            )
            modelContext.insert(event)
        }

        try? modelContext.save()
    }

    private func delete() {
        guard let event else { return }
        modelContext.delete(event)
        try? modelContext.save()
    }
}
