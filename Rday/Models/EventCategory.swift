import Foundation

enum EventCategory: String, CaseIterable, Codable, Identifiable {
    case none = ""
    case anniversary = "anniversary"
    case work = "work"
    case life = "life"
    case custom = "custom"

    var id: Self { self }

    var displayName: String {
        switch self {
        case .none: return "未分类"
        case .anniversary: return "纪念日"
        case .work: return "工作"
        case .life: return "生活"
        case .custom: return "自定义"
        }
    }

    var defaultGradient: (start: String, end: String) {
        switch self {
        case .none: return ("6C63FF", "48C9B0")
        case .anniversary: return ("FF6B6B", "EE5A24")
        case .work: return ("4A90D9", "357ABD")
        case .life: return ("50C878", "2ECC71")
        case .custom: return ("9B59B6", "8E44AD")
        }
    }
}
