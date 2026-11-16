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

    init(
        id: UUID = UUID(),
        title: String = "Untitled",
        content: String = "",
        color: NoteColor = .yellow,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}