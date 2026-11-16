import SwiftUI
import AppKit

@main
struct Nottiq: App {
    @State private var store = NoteStore()
    @State private var windowManager = NoteWindowManager()

    var body: some Scene {
        MenuBarExtra("Nottiq", systemImage: "note.text") {
            Button("New Note") {
                let note = store.createNote()
                windowManager.openWindow(for: note, store: store)
            }
            Button("Show All Notes") { windowManager.showAll() }
            Button("Hide All Notes") { windowManager.hideAll() }
            Divider()
            Button("Quit Nottiq") { NSApp.terminate(nil) }
                .keyboardShortcut("q")
        }
    }
}