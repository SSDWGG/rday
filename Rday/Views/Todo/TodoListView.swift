import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TodoListViewModel()

    @Query(sort: \TodoItem.displayOrder, order: .forward)
    private var todos: [TodoItem]

    var displayedTodos: [TodoItem] {
        viewModel.filter(viewModel.sort(todos))
    }

    private var pendingCount: Int {
        todos.filter { !$0.isCompleted }.count
    }

    var body: some View {
        NavigationStack {
            Group {
                if todos.isEmpty {
                    EmptyStateView(
                        systemImage: "checklist",
                        title: "还没有待办事项",
                        description: "点击右上角 + 添加你的第一个待办"
                    )
                } else if displayedTodos.isEmpty {
                    EmptyStateView(
                        systemImage: "tray",
                        title: "没有匹配的待办",
                        description: "尝试调整筛选条件"
                    )
                } else {
                    List {
                        Section {
                            ForEach(displayedTodos) { todo in
                                NavigationLink(value: todo) {
                                    TodoRowView(todo: todo)
                                }
                            }
                            .onDelete(perform: deleteTodos)
                        } header: {
                            if !displayedTodos.isEmpty {
                                HStack {
                                    Text("共 \(displayedTodos.count) 项")
                                    Spacer()
                                    Text("待完成 \(pendingCount)")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(Constants.todoTabTitle)
            .navigationDestination(for: TodoItem.self) { todo in
                TodoDetailView(todo: todo)
            }
            .searchable(text: $viewModel.searchText, prompt: "搜索待办")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Menu {
                            ForEach(TodoListViewModel.FilterOption.allCases) { option in
                                Button {
                                    viewModel.filterOption = option
                                } label: {
                                    Label(option.rawValue, systemImage: viewModel.filterOption == option ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                        }

                        Menu {
                            ForEach(TodoListViewModel.SortOrder.allCases) { order in
                                Button {
                                    viewModel.sortOrder = order
                                } label: {
                                    Label(order.rawValue, systemImage: viewModel.sortOrder == order ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }

                        Button {
                            viewModel.presentForm()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingForm) {
                TodoFormView(todo: viewModel.editingTodo)
            }
        }
    }

    private func deleteTodos(at offsets: IndexSet) {
        for index in offsets {
            let todo = displayedTodos[index]
            NotificationService.shared.cancelAllReminders(for: todo.id)
            modelContext.delete(todo)
        }
    }
}
