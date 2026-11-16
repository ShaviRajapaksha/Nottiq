import Foundation
import Observation

@Observable
final class NoteStore {
    var notes: [Note] = []
    static let shared = NoteStore()

    private var saveTask: Task<Void, Never>?

    private init() {
        let loaded = NotePersistence.load()
        if loaded.isEmpty {
            notes = [
                Note(
                    title: "Welcome",
                    content: "This is your first note. Edit me!",
                    color: .yellow
                )
            ]
        } else {
            notes = loaded
        }
    }

    func addNote(_ note: Note) {
        notes.append(note)
        scheduleSave()
    }

    func createNote() -> Note {
        let note = Note()
        notes.append(note)
        scheduleSave()
        return note
    }

    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        scheduleSave()
    }

    func updateNote(_ updated: Note) {
        guard let index = notes.firstIndex(where: { $0.id == updated.id }) else { return }
        var copy = updated
        copy.updatedAt = Date()
        notes[index] = copy
        scheduleSave()
    }

    // MARK: - Debounced save

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            if Task.isCancelled { return }
            guard let self else { return }
            let snapshot = self.notes
            await MainActor.run {
                NotePersistence.save(snapshot)
            }
        }
    }

    func flushSave() {
        saveTask?.cancel()
        saveTask = nil
        NotePersistence.save(notes)
    }
}