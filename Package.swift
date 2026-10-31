// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Govi",
    defaultLocalization: "pt-BR",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Govi",
            targets: ["Govi"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Govi",
            dependencies: [],
            path: "Sources/Govi"
        ),
        .testTarget(
            name: "GoviTests",
            dependencies: ["Govi"],
            path: "Tests/GoviTests"
        ),
    ]
)
