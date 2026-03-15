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
            url: "https://github.com/shivaduke28/swift-slang/releases/download/slang-binary/v2026.4.2/SlangBinary.xcframework.zip",
            checksum: "801f1bf3fd76767a83404f34ce5461c40e35dc1e156ff06516116ddff120425f"
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
    ],
    cxxLanguageStandard: .cxx17
)
