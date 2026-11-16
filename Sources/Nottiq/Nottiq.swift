import SwiftUI
import AppKit

@main
struct Nottiq: App {
    @State private var store = NoteStore.shared
    @State private var windowManager = NoteWindowManager.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Nottiq", systemImage: "note.text") {
            Button("New Note") {
                let note = store.createNote()
                windowManager.openWindow(for: note, store: store)
            }
            Button("Show All Notes") { windowManager.showAll() }
            Button("Hide All Notes") { windowManager.hideAll() }
            Divider()
            Button("Preferences…") {
                PreferencesWindowController.shared.showWindow(nil)
            }
            .keyboardShortcut(",", modifiers: .command)
            Divider()
            Button("Quit Nottiq") { NSApp.terminate(nil) }
                .keyboardShortcut("q")
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NoteWindowManager.shared.openAllNotes(from: NoteStore.shared)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        NoteStore.shared.flushSave()
    }
}