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

        // Regular NSWindow with a titled style mask — reliable, focusable, activatable.
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

        // Visual style — do NOT set isOpaque=false with NSPanel; NSWindow is fine.
        window.isReleasedWhenClosed = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true

        // Level and Spaces behavior — set once, before showing.
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.minSize = NSSize(width: 220, height: 220)

        // Restore frame or use default
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

        // Step 1: ensure the app is regular (menu-bar apps default to accessory,
        // and accessory apps can't reliably become active for window focus).
        if NSApp.activationPolicy() != .regular {
            NSApp.setActivationPolicy(.regular)
        }

        // Step 2: activate the app WITHOUT the deprecated flag.
        NSApp.activate()

        // Step 3: make the window visible and key.
        window.makeKeyAndOrderFront(nil)

        // Step 4: force the window onto the current Space, even in accessory mode.
        window.orderFrontRegardless()

        print("showWindow: isVisible=\(window.isVisible) isKey=\(window.isKeyWindow) frame=\(window.frame)")
    }

    func show() { showWindow(nil) }
    func hide() { window?.orderOut(nil) }

    // MARK: - NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        if let frame = window?.frame {
            FrameStore.saveFrame(frame, for: noteID)
        }
        onClose?(noteID)
    }
}

// Plain NSWindow subclass. No NSPanel; the `.titled` style + `canBecomeKey` is
// sufficient for text input, and NSWindow respects activation/Spaces reliably.
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