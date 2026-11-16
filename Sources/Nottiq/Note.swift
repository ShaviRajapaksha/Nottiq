import Foundation

enum NoteColor: String, CaseIterable, Codable {
    case yellow, pink, blue, green, purple, white
}

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var color: NoteColor
    var createdAt: Date
    var updatedAt: Date
    var isAlwaysOnTop: Bool

    init(
        id: UUID = UUID(),
        title: String = "Untitled",
        content: String = "",
        color: NoteColor = .yellow,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isAlwaysOnTop: Bool = true
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isAlwaysOnTop = isAlwaysOnTop
    }

    // Custom decoder so old notes.json files (without isAlwaysOnTop) still load.
    private enum CodingKeys: String, CodingKey {
        case id, title, content, color, createdAt, updatedAt, isAlwaysOnTop
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        content = try c.decode(String.self, forKey: .content)
        color = try c.decode(NoteColor.self, forKey: .color)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)
        isAlwaysOnTop = try c.decodeIfPresent(Bool.self, forKey: .isAlwaysOnTop) ?? true
    }
}