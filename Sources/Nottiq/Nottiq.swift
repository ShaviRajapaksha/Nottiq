import SwiftUI

@main
struct StickyNotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "note.text")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
            Text("Sticky Notes Foundation")
                .font(.title2)
                .fontWeight(.semibold)
            Text("If you can see this window, your environment works.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .frame(minWidth: 320, minHeight: 240)
    }
}