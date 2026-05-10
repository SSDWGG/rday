import SwiftUI

@Observable
final class CountdownListViewModel {
    enum SortOrder: String, CaseIterable, Identifiable {
        case dateAscending = "最近优先"
        case dateDescending = "最远优先"
        case createdAt = "创建时间"

        var id: Self { self }
    }

    var sortOrder: SortOrder = .dateAscending
    var searchText: String = ""
    var categoryFilter: EventCategory? = nil
    var showPinnedFirst: Bool = true
    var isShowingForm: Bool = false
    var editingEvent: CountdownEvent?

    var pinnedEvents: [CountdownEvent] = []
    var unpinnedEvents: [CountdownEvent] = []

    func sort(_ events: [CountdownEvent]) -> [CountdownEvent] {
        events.sorted { a, b in
            if showPinnedFirst {
                if a.isPinned != b.isPinned { return a.isPinned }
            }
            switch sortOrder {
            case .dateAscending:
                return a.targetDate < b.targetDate
            case .dateDescending:
                return a.targetDate > b.targetDate
            case .createdAt:
                return a.createdAt > b.createdAt
            }
        }
    }

    func filter(_ events: [CountdownEvent]) -> [CountdownEvent] {
        var result = events
        if let category = categoryFilter {
            result = result.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    func presentForm(for event: CountdownEvent? = nil) {
        editingEvent = event
        isShowingForm = true
    }

    func dismissForm() {
        isShowingForm = false
        editingEvent = nil
    }
}
