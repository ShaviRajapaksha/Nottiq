// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Nottiq",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Nottiq",
            path: "Sources/Nottiq"
        )
    ]
)