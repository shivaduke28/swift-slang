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
            url: "https://github.com/shivaduke28/swift-slang/releases/download/slang-binary/v2026.13.1/SlangBinary.xcframework.zip",
            checksum: "c8022365f2133bc378a91ab00cf3a4b1ff8729cb7ec2a96e877a3ee3793bafc6"
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
