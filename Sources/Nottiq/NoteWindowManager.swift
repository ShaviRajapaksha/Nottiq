import AppKit

final class NoteWindowManager {
    static let shared = NoteWindowManager()
    private init() {}

    private var controllers: [UUID: NoteWindowController] = [:]

    func openWindow(for note: Note, store: NoteStore) {
        if let existing = controllers[note.id] {
            existing.show()
            return
        }

        let controller = NoteWindowController(
            note: note,
            store: store,
            windowManager: self
        )

        controllers[note.id] = controller

        controller.onClose = { [weak self] id in
            self?.controllers[id] = nil
            self?.demoteIfEmpty()
        }

        controller.show()

        if let window = controller.window {
            window.isMovableByWindowBackground = true
        }
    }

    func closeWindow(for id: UUID) {
        guard let controller = controllers[id] else { return }
        controllers[id] = nil
        controller.onClose = nil
        controller.close()
        demoteIfEmpty()
    }

    func hide(noteID: UUID) {
        controllers[noteID]?.hide()
        demoteIfEmpty()
    }

    func showAll() {
        for controller in controllers.values { controller.show() }
    }

    func hideAll() {
        for controller in controllers.values { controller.hide() }
        demoteIfEmpty()
    }

    func openAllNotes(from store: NoteStore) {
        for note in store.notes {
            openWindow(for: note, store: store)
        }
    }

    func setWindowLevel(noteID: UUID, level: NoteWindowLevel) {
        controllers[noteID]?.setWindowLevel(level)
    }

    private func demoteIfEmpty() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let hasVisible = self.controllers.values.contains { controller in
                controller.window?.isVisible == true
            }
            if !hasVisible {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
}