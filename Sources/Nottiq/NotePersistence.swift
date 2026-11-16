import Foundation

enum NotePersistence {
    private static var directoryURL: URL {
        let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        return base.appendingPathComponent("Nottiq", isDirectory: true)
    }

    private static var fileURL: URL {
        directoryURL.appendingPathComponent("notes.json")
    }

    static func load() -> [Note] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Note].self, from: data)
        } catch {
            print("NotePersistence.load failed: \(error)")
            return []
        }
    }

    static func save(_ notes: [Note]) {
        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(notes)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("NotePersistence.save failed: \(error)")
        }
    }
}