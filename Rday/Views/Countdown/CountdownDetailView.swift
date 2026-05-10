import SwiftUI
import SwiftData

struct CountdownDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let event: CountdownEvent

    @State private var isEditing: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showShareSheet: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                EventCardView(event: event)
                    .frame(height: 260)
                    .padding(.horizontal, DesignSystem.Layout.cardHorizontalPadding)
                    .padding(.top, DesignSystem.Layout.cardSpacing)

                VStack(alignment: .leading, spacing: 16) {
                    detailRow(title: "事件", value: event.title)
                    detailRow(title: "日期", value: DateHelper.formattedDate(event.targetDate))
                    detailRow(title: "类型", value: event.isCountdown ? "倒数日" : "纪念日")

                    if let note = event.note, !note.isEmpty {
                        detailRow(title: "备注", value: note)
                    }
                }
                .padding(DesignSystem.Layout.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Button {
                        isEditing = true
                    } label: {
                        Text("编辑")
                    }

                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            CountdownFormView(event: event)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = generateShareImage() {
                ShareSheet(image: image)
            }
        }
        .confirmationDialog("确定删除此事件吗？", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                modelContext.delete(event)
                try? modelContext.save()
                dismiss()
            }
            Button("取消", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }

    private func generateShareImage() -> UIImage? {
        let view = ShareCardView(event: event)
            .frame(width: 1080, height: 1080)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        renderer.proposedSize = .init(width: 1080, height: 1080)
        return renderer.uiImage
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
