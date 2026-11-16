import AppKit
import SwiftUI

final class PreferencesWindowController: NSWindowController {
    static let shared = PreferencesWindowController()

    private init() {
        let view = PreferencesView()
        let hosting = NSHostingController(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Nottiq Preferences"
        window.contentViewController = hosting
        window.center()
        window.isReleasedWhenClosed = false
        super.init(window: window)
    }

    required init?(coder: NSCoder) { fatalError("Not supported") }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        if NSApp.activationPolicy() != .regular {
            NSApp.setActivationPolicy(.regular)
        }
        NSApp.activate()
        window?.makeKeyAndOrderFront(nil)
    }
}

private struct PreferencesView: View {
    @State private var launchAtLogin = false

    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .disabled(true)
                Text("Coming in a future update.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Startup")
            }

            Section {
                Text("Nottiq 0.2.0")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("A lightweight sticky-notes app for macOS.")
                    .font(.caption)
            } header: {
                Text("About")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}