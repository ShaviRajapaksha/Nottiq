import AppKit

final class NoteWindowManager {
    private var controllers: [UUID: NoteWindowController] = [:]

    func openWindow(for note: Note, store: NoteStore) {
        if let existing = controllers[note.id] {
            existing.show()
            return
        }

        let controller = NoteWindowController(note: note, store: store, windowManager: self)
        controllers[note.id] = controller
        controller.onClose = { [weak self] id in
            self?.controllers[id] = nil
        }
        controller.show()
    }

    func closeWindow(for id: UUID) {
        guard let controller = controllers[id] else { return }
        controllers[id] = nil
        controller.onClose = nil
        controller.close()
    }

    func hide(noteID: UUID) {
        controllers[noteID]?.hide()
    }

    func showAll() {
        for controller in controllers.values { controller.show() }
    }

    func hideAll() {
        for controller in controllers.values { controller.hide() }
    }

    func openAllNotes(from store: NoteStore) {
        for note in store.notes {
            openWindow(for: note, store: store)
        }
    }
}