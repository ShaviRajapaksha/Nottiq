import AppKit

enum FrameStore {
    private static let key = "note.frames.v1"

    private static var storage: [String: [String: CGFloat]] {
        get {
            let raw = UserDefaults.standard.dictionary(forKey: key) ?? [:]
            var result: [String: [String: CGFloat]] = [:]
            for (noteID, value) in raw {
                if let dict = value as? [String: CGFloat] {
                    result[noteID] = dict
                } else if let dict = value as? [String: NSNumber] {
                    result[noteID] = dict.mapValues { CGFloat(truncating: $0) }
                }
            }
            return result
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    static func saveFrame(_ frame: NSRect, for id: UUID) {
        var all = storage
        all[id.uuidString] = [
            "x": frame.origin.x,
            "y": frame.origin.y,
            "w": frame.size.width,
            "h": frame.size.height
        ]
        storage = all
    }

    static func loadFrame(for id: UUID) -> NSRect? {
        guard let dict = storage[id.uuidString],
              let x = dict["x"], let y = dict["y"],
              let w = dict["w"], let h = dict["h"] else { return nil }
        return NSRect(x: x, y: y, width: w, height: h)
    }

    static func removeFrame(for id: UUID) {
        var all = storage
        all.removeValue(forKey: id.uuidString)
        storage = all
    }
}