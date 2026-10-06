// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftSlang",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Slang",
            targets: ["Slang"]
        ),
        .library(
            name: "SwiftSlang",
            targets: ["SwiftSlang"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SlangBinary",
            url: "https://github.com/shivaduke28/swift-slang/releases/download/slang-binary/v2026.19/SlangBinary.xcframework.zip",
            checksum: "73d28a7bcc1aba0858fd9b3a301bce6f0e2d478def63b371313070f9fb302e9d"
        ),

        .target(
            name: "Slang",
            dependencies: ["SlangBinary"],
            path: "Sources/Slang",
            publicHeadersPath: "include",
            cxxSettings: [
                .define("SLANG_DYNAMIC", to: "0"),
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
            ]
        ),

        .target(
            name: "SwiftSlang",
            dependencies: ["Slang", "SlangBinary"],
            path: "Sources/SwiftSlang",
            publicHeadersPath: ".",
            cxxSettings: [
                .define("SLANG_DYNAMIC", to: "0"),
                .headerSearchPath("../Slang"),
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
            ]
        ),
        .testTarget(
            name: "SwiftSlangTests",
            dependencies: ["SwiftSlang"]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
