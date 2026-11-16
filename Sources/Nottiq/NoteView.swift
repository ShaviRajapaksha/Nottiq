import SwiftUI
import AppKit

struct NoteView: View {
    let noteID: UUID
    let store: NoteStore
    let windowManager: NoteWindowManager

    private var note: Note? {
        store.notes.first { $0.id == noteID }
    }

    var body: some View {
        if let note = note {
            VStack(alignment: .leading, spacing: 0) {
                titleBar(note)
                Divider().opacity(0.15)
                contentArea(note)
            }
            .background(noteColor(note.color))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 4)
        }
    }

    private func titleBar(_ note: Note) -> some View {
        HStack(spacing: 6) {
            TextField("Title", text: Binding(
                get: { self.note?.title ?? "" },
                set: { newTitle in
                    guard var n = self.note else { return }
                    n.title = newTitle
                    store.updateNote(n)
                }
            ))
            .textFieldStyle(.plain)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.black.opacity(0.75))

            Spacer(minLength: 0)

            // Color picker
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
                                .overlay(Circle().stroke(Color.black.opacity(0.15)))
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
                    .overlay(Circle().stroke(Color.black.opacity(0.2), lineWidth: 0.5))
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()

            // Actions menu
            Menu {
                Button("Duplicate") {
                    duplicateNote(note)
                }
                Button(
                    "Always on Top",
                    systemImage: note.isAlwaysOnTop ? "checkmark.circle.fill" : "circle"
                ) {
                    guard var n = self.note else { return }
                    n.isAlwaysOnTop.toggle()
                    store.updateNote(n)
                    windowManager.setAlwaysOnTop(noteID: noteID, enabled: n.isAlwaysOnTop)
                }
                Divider()
                Button("Delete Note", role: .destructive) {
                    windowManager.closeWindow(for: noteID)
                    FrameStore.removeFrame(for: noteID)
                    store.deleteNote(id: noteID)
                }
                Divider()
                Button("Hide") {
                    windowManager.hide(noteID: noteID)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 13))
                    .foregroundStyle(.black.opacity(0.5))
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.03))
    }

    private func duplicateNote(_ note: Note) {
        let copy = Note(
            title: note.title.isEmpty ? "Untitled copy" : "\(note.title) copy",
            content: note.content,
            color: note.color,
            isAlwaysOnTop: note.isAlwaysOnTop
        )
        store.addNote(copy)
        windowManager.openWindow(for: copy, store: store)
    }

    private func swatchColor(_ color: NoteColor) -> Color {
        switch color {
        case .yellow: return Color(red: 1.00, green: 0.95, blue: 0.62)
        case .pink:   return Color(red: 1.00, green: 0.80, blue: 0.86)
        case .blue:   return Color(red: 0.79, green: 0.90, blue: 1.00)
        case .green:  return Color(red: 0.82, green: 0.97, blue: 0.80)
        case .purple: return Color(red: 0.88, green: 0.80, blue: 1.00)
        case .white:  return Color(white: 0.99)
        }
    }

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
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    private func noteColor(_ color: NoteColor) -> Color {
        switch color {
        case .yellow: return Color(red: 1.00, green: 0.95, blue: 0.62)
        case .pink:   return Color(red: 1.00, green: 0.80, blue: 0.86)
        case .blue:   return Color(red: 0.79, green: 0.90, blue: 1.00)
        case .green:  return Color(red: 0.82, green: 0.97, blue: 0.80)
        case .purple: return Color(red: 0.88, green: 0.80, blue: 1.00)
        case .white:  return Color(white: 0.99)
        }
    }
}