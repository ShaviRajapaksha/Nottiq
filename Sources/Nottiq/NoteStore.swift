import Foundation
import Observation

@Observable
final class NoteStore {
    var notes: [Note] = []

    init() {
        let starter = Note(
            title: "Welcome",
            content: "This is your first note. Edit me!",
            color: .yellow
        )
        notes = [starter]
    }

    func createNote() -> Note {
        let note = Note()
        notes.append(note)
        return note
    }

    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
    }

    func updateNote(_ updated: Note) {
        guard let index = notes.firstIndex(where: { $0.id == updated.id }) else { return }
        var copy = updated
        copy.updatedAt = Date()
        notes[index] = copy
    }
}