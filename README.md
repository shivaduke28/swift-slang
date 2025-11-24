# SwiftSlang

A wrapper of [Slang](https://github.com/shader-slang/slang) for Swift.

## Slang Version

This package uses **Slang v2025.22**.

## Note

This package only exposes a minimal subset of the Slang API that the author needs.

## License

This project is licensed under **Apache 2.0 with LLVM exception** (same as Slang).

This package includes:
- **Slang headers** (`Sources/Slang/include/`) - from [shader-slang/slang](https://github.com/shader-slang/slang)
- **Slang binary** (XCFramework) - prebuilt from [shader-slang/slang](https://github.com/shader-slang/slang)
- **SwiftSlang wrapper** (`Sources/SwiftSlang/`) - Objective-C++ wrapper for Swift interop

See [LICENSE](LICENSE) for the full license text.
