import SwiftUI
import SwiftData

struct CountdownListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CountdownListViewModel()
    @State private var showDateCalculator: Bool = false

    @Query(sort: \CountdownEvent.displayOrder, order: .forward)
    private var events: [CountdownEvent]

    var displayedEvents: [CountdownEvent] {
        viewModel.filter(viewModel.sort(events))
    }

    var body: some View {
        NavigationStack {
            Group {
                if events.isEmpty {
                    EmptyStateView(
                        systemImage: "calendar.badge.clock",
                        title: "还没有倒数日",
                        description: "点击右上角 + 添加你的第一个事件"
                    )
                } else {
                    VStack(spacing: 0) {
                        categoryFilterBar

                        if displayedEvents.isEmpty && !viewModel.searchText.isEmpty {
                            EmptyStateView(
                                systemImage: "magnifyingglass",
                                title: "没有找到",
                                description: "尝试其他关键词"
                            )
                        } else {
                            List {
                                ForEach(displayedEvents) { event in
                                    EventCardView(event: event)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(
                                            top: DesignSystem.Layout.cardSpacing / 2,
                                            leading: DesignSystem.Layout.cardHorizontalPadding,
                                            bottom: DesignSystem.Layout.cardSpacing / 2,
                                            trailing: DesignSystem.Layout.cardHorizontalPadding
                                        ))
                                        .listRowBackground(Color.clear)
                                        .overlay {
                                            NavigationLink(value: event) {
                                                EmptyView()
                                            }
                                            .opacity(0)
                                        }
                                }
                                .onDelete(perform: deleteEvents)
                            }
                            .listStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle(Constants.countdownTabTitle)
            .navigationDestination(for: CountdownEvent.self) { event in
                CountdownDetailView(event: event)
            }
            .searchable(text: $viewModel.searchText, prompt: "搜索事件")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDateCalculator = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(CountdownListViewModel.SortOrder.allCases) { order in
                            Button {
                                viewModel.sortOrder = order
                            } label: {
                                Label(order.rawValue, systemImage: viewModel.sortOrder == order ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.presentForm()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingForm) {
                CountdownFormView(event: viewModel.editingEvent)
            }
            .sheet(isPresented: $showDateCalculator) {
                DateCalculatorView()
            }
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    viewModel.categoryFilter = nil
                } label: {
                    Text("全部")
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.categoryFilter == nil ? Color.accentColor : Color(.systemGray5))
                        .foregroundColor(viewModel.categoryFilter == nil ? .white : .primary)
                        .clipShape(Capsule())
                }

                ForEach(EventCategory.allCases.filter { $0 != .none }) { category in
                    Button {
                        viewModel.categoryFilter = viewModel.categoryFilter == category ? nil : category
                    } label: {
                        Text(category.displayName)
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.categoryFilter == category ? categoryFilterColor(category) : Color(.systemGray5))
                            .foregroundColor(viewModel.categoryFilter == category ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Layout.cardHorizontalPadding)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func categoryFilterColor(_ category: EventCategory) -> Color {
        switch category {
        case .anniversary: return DesignSystem.Color.categoryAnniversary
        case .work: return DesignSystem.Color.categoryWork
        case .life: return DesignSystem.Color.categoryLife
        case .custom: return DesignSystem.Color.categoryCustom
        case .none: return .accentColor
        }
    }

    private func deleteEvents(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(displayedEvents[index])
        }
    }
}
