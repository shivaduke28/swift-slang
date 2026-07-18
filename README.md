# SwiftSlang

A wrapper of [Slang](https://github.com/shader-slang/slang) for Swift.

## Slang Version

This package uses **Slang v2026.13.1**.

## Note

This package only exposes a minimal subset of the Slang API that the author needs.

## Branching & Release

- Development happens on `main`, which contains the [shader-slang/slang](https://github.com/shader-slang/slang) repository as a git submodule (`slang/`) for building the XCFramework and copying headers.
- There are two kinds of releases:
  - **Slang binary releases** (`slang-binary/vYYYY.MM.P` tags): prebuilt `SlangBinary.xcframework.zip` built locally on an Apple Silicon Mac and uploaded manually when updating the Slang version. `Package.swift` references this release by URL and checksum.
  - **Package releases** (`vX.Y.Z` tags): created by the [Release workflow](.github/workflows/release.yml) via `workflow_dispatch`. The workflow removes the `slang` submodule and `.gitmodules`, creates a release commit, and pushes only the tag — so release tags point to a commit **without the submodule**, and that commit is intentionally not part of `main`.
- Consumers resolving a `vX.Y.Z` tag therefore never clone the Slang submodule; they download the prebuilt XCFramework via `Package.swift` instead.

## License

This project is licensed under **Apache 2.0 with LLVM exception** (same as Slang).

This package includes:
- **Slang headers** (`Sources/Slang/include/`) - from [shader-slang/slang](https://github.com/shader-slang/slang)
- **Slang binary** (XCFramework) - prebuilt from [shader-slang/slang](https://github.com/shader-slang/slang)
- **SwiftSlang wrapper** (`Sources/SwiftSlang/`) - Objective-C++ wrapper for Swift interop

See [LICENSE](LICENSE) for the full license text.
