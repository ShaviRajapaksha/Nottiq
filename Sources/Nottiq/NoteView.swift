import SwiftUI
import AppKit

private enum Glass {
    static let base = Color(red: 30/255, green: 28/255, blue: 53/255)
    static let radius: CGFloat = 22
    static let shadowColor = Color.black.opacity(0.55)
    static let shadowRadius: CGFloat = 28
    static let shadowY: CGFloat = 12
    static let lightTop = Color.white.opacity(0.06)
    static let lightMid = Color.white.opacity(0.015)
    static let lightBottom = Color.white.opacity(0.05)
}

struct NoteView: View {
    let noteID: UUID
    let store: NoteStore
    let windowManager: NoteWindowManager

    private var note: Note? {
        store.notes.first { $0.id == noteID }
    }

    var body: some View {
        if let note = note {
            ZStack {
                // Main sticker background
                noteColor(note.color)

                // Glass effect — clipped at the AppKit layer to the rounded rect
                RoundedVisualEffectView(
                    material: .hudWindow,
                    blending: .behindWindow,
                    cornerRadius: Glass.radius
                )
                .allowsHitTesting(false)

                // Subtle glass lighting
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.10),
                        Color.white.opacity(0.02),
                        Color.black.opacity(0.03)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 0) {
                    dragHeader(note)

                    Divider()
                        .overlay(Color.black.opacity(0.10))

                    topBar(note)

                    Divider()
                        .overlay(Color.black.opacity(0.10))

                    contentArea(note)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Glass.radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Glass.radius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Glass.radius, style: .continuous)
                    .stroke(Color.white.opacity(0.04), lineWidth: 8)
                    .blur(radius: 8)
                    .offset(y: 4)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.6),
                                .init(color: .white, location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .allowsHitTesting(false)
            )
            .shadow(color: Glass.shadowColor, radius: Glass.shadowRadius, x: 0, y: Glass.shadowY)
            .contextMenu {
                backgroundContextMenu(note)
            }
        }
    }

    // MARK: - Drag header (top strip only, for moving the window)

    private func dragHeader(_ note: Note) -> some View {
        HStack(spacing: 8) {
            DragGrip()

            Spacer(minLength: 0)

            Menu {
                ForEach(NoteColor.allCases, id: \.self) { color in
                    Button {
                        guard var n = self.note else { return }
                        n.color = color
                        store.updateNote(n)
                    } label: {
                        HStack {
                            Circle()
                                .fill(swatchColor(color))
                                .frame(width: 12, height: 12)
                                .overlay(Circle().stroke(Color.white.opacity(0.3)))
                            Text(color.rawValue.capitalized)
                            if note.color == color {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Circle()
                    .fill(swatchColor(note.color))
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 0.5))
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()

            Menu {
                actionsMenu(note)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()

            Button {
                closeNote()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .help("Close note")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color.white.opacity(0.10), Color.white.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                WindowDragHandle()
            }
        )
    }

    // MARK: - Title bar (below the header, not a drag target)

    private func topBar(_ note: Note) -> some View {
        HStack(spacing: 8) {
            TextField("Untitled", text: Binding(
                get: { self.note?.title ?? "" },
                set: { newTitle in
                    guard var n = self.note else { return }
                    n.title = newTitle
                    store.updateNote(n)
                }
            ))
            .textFieldStyle(.plain)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
    }

    // MARK: - Menus

    @ViewBuilder
    private func actionsMenu(_ note: Note) -> some View {
        Button("Duplicate") { duplicateNote(note) }
        Menu("Window Level") { levelOptions(note) }
        Divider()
        Button("Delete Note", role: .destructive) { deleteNote() }
        Divider()
        Button("Hide") { windowManager.hide(noteID: noteID) }
    }

    @ViewBuilder
    private func levelOptions(_ note: Note) -> some View {
        Button { updateLevel(.normal) } label: {
            HStack { Text("Normal"); if note.windowLevel == .normal { Image(systemName: "checkmark") } }
        }
        Button { updateLevel(.alwaysOnTop) } label: {
            HStack { Text("Always on Top"); if note.windowLevel == .alwaysOnTop { Image(systemName: "checkmark") } }
        }
        Button { updateLevel(.alwaysOnBack) } label: {
            HStack { Text("Always on Back"); if note.windowLevel == .alwaysOnBack { Image(systemName: "checkmark") } }
        }
    }

    @ViewBuilder
    private func backgroundContextMenu(_ note: Note) -> some View {
        Button("Duplicate") { duplicateNote(note) }
        Menu("Window Level") { levelOptions(note) }
        Menu("Change Color") {
            ForEach(NoteColor.allCases, id: \.self) { color in
                Button(color.rawValue.capitalized) {
                    guard var n = self.note else { return }
                    n.color = color
                    store.updateNote(n)
                }
            }
        }
        Divider()
        Button("Delete Note", role: .destructive) { deleteNote() }
        Button("Close") { closeNote() }
    }

    // MARK: - Content

    private func contentArea(_ note: Note) -> some View {
        TextEditor(text: Binding(
            get: { self.note?.content ?? "" },
            set: { newContent in
                guard var n = self.note else { return }
                n.content = newContent
                store.updateNote(n)
            }
        ))
        .font(.system(size: 13))
        .foregroundStyle(.white)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    // MARK: - Actions

    private func duplicateNote(_ note: Note) {
        let copy = Note(
            title: note.title.isEmpty ? "Untitled copy" : "\(note.title) copy",
            content: note.content,
            color: note.color,
            windowLevel: note.windowLevel
        )
        store.addNote(copy)
        windowManager.openWindow(for: copy, store: store)
    }

    private func closeNote() { windowManager.hide(noteID: noteID) }
    private func deleteNote() {
        windowManager.closeWindow(for: noteID)
        FrameStore.removeFrame(for: noteID)
        store.deleteNote(id: noteID)
    }
    private func updateLevel(_ level: NoteWindowLevel) {
        guard var n = self.note else { return }
        n.windowLevel = level
        store.updateNote(n)
        windowManager.setWindowLevel(noteID: noteID, level: level)
    }

    // MARK: - Colors

    private func swatchColor(_ color: NoteColor) -> Color {
        switch color {
        case .yellow: return Color(red: 1.00, green: 0.88, blue: 0.40)
        case .pink:   return Color(red: 1.00, green: 0.65, blue: 0.78)
        case .blue:   return Color(red: 0.60, green: 0.82, blue: 1.00)
        case .green:  return Color(red: 0.66, green: 0.94, blue: 0.64)
        case .purple: return Color(red: 0.80, green: 0.68, blue: 1.00)
        case .white:  return Color(white: 0.97)
        }
    }

    private func noteColor(_ color: NoteColor) -> Color { swatchColor(color) }
}

// MARK: - Rounded NSVisualEffectView bridge

/// An `NSVisualEffectView` that clips its own blur output to a rounded rect.
final class RoundedVisualEffectNSView: NSVisualEffectView {
    var cornerRadius: CGFloat = 0

    override func layout() {
        super.layout()
        wantsLayer = true
        layer?.cornerRadius = cornerRadius
        layer?.cornerCurve = .continuous
        layer?.masksToBounds = true
    }
}

struct RoundedVisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blending: NSVisualEffectView.BlendingMode
    var cornerRadius: CGFloat

    func makeNSView(context: Context) -> RoundedVisualEffectNSView {
        let view = RoundedVisualEffectNSView()
        view.material = material
        view.blendingMode = blending
        view.state = .active
        view.isEmphasized = true
        view.cornerRadius = cornerRadius
        return view
    }

    func updateNSView(_ nsView: RoundedVisualEffectNSView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blending
        if nsView.cornerRadius != cornerRadius {
            nsView.cornerRadius = cornerRadius
            nsView.needsLayout = true
        }
    }
}

// MARK: - Drag helpers

struct WindowDragHandle: NSViewRepresentable {
    func makeNSView(context: Context) -> DragView { DragView() }
    func updateNSView(_ nsView: DragView, context: Context) {}

    final class DragView: NSView {
        override var mouseDownCanMoveWindow: Bool { true }
        override func mouseDown(with event: NSEvent) {
            window?.performDrag(with: event)
        }
    }
}

struct DragGrip: View {
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<2) { _ in
                VStack(spacing: 2) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.28))
                            .frame(width: 2.5, height: 2.5)
                    }
                }
            }
        }
        .frame(width: 12)
        .help("Drag to move")
    }
}