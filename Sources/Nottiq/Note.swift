import Foundation

enum NoteColor: String, CaseIterable, Codable {
    case yellow, pink, blue, green, purple, white
}

enum NoteWindowLevel: String, Codable, CaseIterable {
    case normal
    case alwaysOnTop
    case alwaysOnBack
}

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var color: NoteColor
    var createdAt: Date
    var updatedAt: Date
    var windowLevel: NoteWindowLevel

    // Backward-compat convenience — existing code that reads `isAlwaysOnTop` still works.
    var isAlwaysOnTop: Bool {
        get { windowLevel == .alwaysOnTop }
        set { windowLevel = newValue ? .alwaysOnTop : .normal }
    }

    init(
        id: UUID = UUID(),
        title: String = "Untitled",
        content: String = "",
        color: NoteColor = .yellow,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        windowLevel: NoteWindowLevel = .normal
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.windowLevel = windowLevel
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, content, color, createdAt, updatedAt, windowLevel, isAlwaysOnTop
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        content = try c.decode(String.self, forKey: .content)
        color = try c.decode(NoteColor.self, forKey: .color)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)

        // Prefer new key; fall back to old boolean for backward compatibility.
        if let level = try c.decodeIfPresent(NoteWindowLevel.self, forKey: .windowLevel) {
            windowLevel = level
        } else if let oldBool = try c.decodeIfPresent(Bool.self, forKey: .isAlwaysOnTop) {
            windowLevel = oldBool ? .alwaysOnTop : .normal
        } else {
            windowLevel = .normal
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(content, forKey: .content)
        try c.encode(color, forKey: .color)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(updatedAt, forKey: .updatedAt)
        try c.encode(windowLevel, forKey: .windowLevel)
        // Do NOT encode isAlwaysOnTop anymore — it's derived.
    }
}