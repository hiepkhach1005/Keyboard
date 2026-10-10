// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KeyboardCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "InputCore", targets: ["InputCore"]),
        .library(name: "SharedSettings", targets: ["SharedSettings"])
    ],
    targets: [
        .target(name: "InputCore"),
        .target(name: "SharedSettings"),
        .executableTarget(
            name: "CoreValidation",
            dependencies: ["InputCore", "SharedSettings"]
        ),
        .testTarget(
            name: "InputCoreTests",
            dependencies: ["InputCore"]
        ),
        .testTarget(
            name: "SharedSettingsTests",
            dependencies: ["SharedSettings"]
        )
    ]
)
