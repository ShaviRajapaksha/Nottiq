import AppKit
import SwiftUI

final class NoteWindowController: NSWindowController, NSWindowDelegate {
    private let noteID: UUID
    private let store: NoteStore
    var onClose: ((UUID) -> Void)?

    init(note: Note, store: NoteStore, windowManager: NoteWindowManager) {
        self.noteID = note.id
        self.store = store

        let noteView = NoteView(noteID: note.id, store: store, windowManager: windowManager)
        let hosting = NSHostingController(rootView: noteView)

        let window = StickyNoteWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 280),
            styleMask: [.titled, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.identifier = NSUserInterfaceItemIdentifier(note.id.uuidString)
        window.contentViewController = hosting

        // Invisible title bar
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none
        window.isMovableByWindowBackground = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        // Visual style
        window.isReleasedWhenClosed = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.minSize = NSSize(width: 220, height: 220)

        // Level from saved preference (inline, since self isn't initialized yet)
        switch note.windowLevel {
        case .normal:
            window.level = .normal
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        case .alwaysOnTop:
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        case .alwaysOnBack:
            window.level = NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue - 1)
            window.collectionBehavior = [.canJoinAllSpaces]
        }

        if let saved = FrameStore.loadFrame(for: note.id) {
            window.setFrame(saved, display: false)
        } else {
            window.setFrame(
                NSRect(x: 200, y: 600, width: 280, height: 280),
                display: false
            )
        }

        super.init(window: window)
        window.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("Not supported") }

    override func showWindow(_ sender: Any?) {
        guard let window else { return }

        if NSApp.activationPolicy() != .regular {
            NSApp.setActivationPolicy(.regular)
        }

        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }

    func show() { showWindow(nil) }
    func hide() { window?.orderOut(nil) }

    func setWindowLevel(_ level: NoteWindowLevel) {
        guard let window else { return }
        switch level {
        case .normal:
            window.level = .normal
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        case .alwaysOnTop:
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        case .alwaysOnBack:
            window.level = NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue - 1)
            window.collectionBehavior = [.canJoinAllSpaces]
        }
        if window.isVisible {
            window.orderFrontRegardless()
        }
    }

    // MARK: - NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        if let frame = window?.frame {
            FrameStore.saveFrame(frame, for: noteID)
        }
        onClose?(noteID)
    }
}

final class StickyNoteWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func mouseDown(with event: NSEvent) {
        if NSApp.activationPolicy() != .regular {
            NSApp.setActivationPolicy(.regular)
        }
        NSApp.activate()
        makeKeyAndOrderFront(nil)
        super.mouseDown(with: event)
    }
}