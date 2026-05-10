import SwiftUI

@Observable
final class TodoListViewModel {
    enum SortOrder: String, CaseIterable, Identifiable {
        case priority = "按优先级"
        case dueDate = "按截止日期"
        case createdAt = "按创建时间"

        var id: Self { self }
    }

    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "全部"
        case pending = "未完成"
        case completed = "已完成"

        var id: Self { self }
    }

    var sortOrder: SortOrder = .dueDate
    var filterOption: FilterOption = .all
    var searchText: String = ""
    var isShowingForm: Bool = false
    var editingTodo: TodoItem?

    func sort(_ todos: [TodoItem]) -> [TodoItem] {
        switch sortOrder {
        case .priority:
            todos.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
        case .dueDate:
            todos.sorted { a, b in
                switch (a.dueDate, b.dueDate) {
                case let (d1?, d2?): return d1 < d2
                case (nil, _): return false
                case (_, nil): return true
                }
            }
        case .createdAt:
            todos.sorted { $0.createdAt > $1.createdAt }
        }
    }

    func filter(_ todos: [TodoItem]) -> [TodoItem] {
        var result = todos

        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }

        switch filterOption {
        case .all: break
        case .pending: result = result.filter { !$0.isCompleted }
        case .completed: result = result.filter { $0.isCompleted }
        }

        return result
    }

    func presentForm(for todo: TodoItem? = nil) {
        editingTodo = todo
        isShowingForm = true
    }

    func dismissForm() {
        isShowingForm = false
        editingTodo = nil
    }
}
