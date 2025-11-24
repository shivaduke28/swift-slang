# Development Guide

SwiftSlang の開発環境構築ガイドです。C++初心者の方でも分かるように詳しく説明しています。

## 目次

- [必要なツール](#必要なツール)
- [プロジェクト構成](#プロジェクト構成)
- [ビルド方法](#ビルド方法)
- [Swift Package としての使い方](#swift-package-としての使い方)
- [よくある問題と対処法](#よくある問題と対処法)
- [開発フロー](#開発フロー)

---

## 必要なツール

### 1. Xcode

**バージョン**: 15.0 以上

App Store からインストールするか、[Apple Developer](https://developer.apple.com/xcode/) からダウンロードしてください。

インストール後、コマンドラインツールを設定します：

```bash
# コマンドラインツールのインストール
xcode-select --install

# バージョン確認
xcodebuild -version
# 出力例: Xcode 15.0 Build version 15A240d
```

### 2. Homebrew

macOS 用のパッケージマネージャーです。CMake や Ninja をインストールするために使います。

```bash
# Homebrew のインストール（未インストールの場合）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# インストール確認
brew --version
# 出力例: Homebrew 4.1.0
```

### 3. CMake

C/C++ プロジェクトのビルドシステムです。Slang は CMake を使ってビルドします。

```bash
# インストール
brew install cmake

# バージョン確認（3.26 以上推奨）
cmake --version
# 出力例: cmake version 3.27.0
```

### 4. Ninja

高速なビルドツールです。CMake と組み合わせて使います。

```bash
# インストール
brew install ninja

# バージョン確認（1.11 以上推奨）
ninja --version
# 出力例: 1.11.1
```

### 全ツールのバージョン確認

```bash
xcodebuild -version && cmake --version && ninja --version
```

---

## プロジェクト構成

```
shader-slang-swift/
├── Sources/
│   ├── Slang/                    # Slang C/C++ ヘッダー
│   │   ├── include/              # slang.h などの公式ヘッダー
│   │   │   ├── slang.h           # メイン API
│   │   │   ├── slang-gfx.h       # グラフィックス API
│   │   │   └── LICENSE.txt       # Slang のライセンス
│   │   ├── module.modulemap      # Swift から C を使うための設定
│   │   └── Slang.c               # ダミーファイル（SPM 要件）
│   │
│   └── SwiftSlang/               # Objective-C++ ラッパー
│       ├── SLGlobalSession.h/mm  # グローバルセッション
│       ├── SLSession.h/mm        # コンパイルセッション
│       ├── SLSessionDesc.h/mm    # セッション設定
│       ├── SLModule.h/mm         # モジュール
│       ├── SLEntryPoint.h/mm     # エントリーポイント
│       ├── SLComponentType.h/mm  # コンポーネント
│       └── module.modulemap
│
├── slang/                        # Slang サブモジュール（ビルド時のみ）
├── toolchains/                   # iOS 用 CMake ツールチェーン
├── build/                        # ビルド成果物（自動生成）
├── xcframework/                  # XCFramework 成果物（自動生成）
│
├── Package.swift                 # Swift Package 定義
├── Makefile                      # ビルドスクリプト
└── docs/
    ├── DEVELOPMENT.md            # このファイル
    └── SLANG_BUILD_GUIDE.md      # Slang ビルドの詳細
```

### モジュールの関係

```
┌─────────────────────────────────────────────────┐
│  Your Swift App                                 │
│  import SwiftSlang                              │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│  SwiftSlang (Objective-C++ Wrapper)             │
│  SLGlobalSession, SLSession, SLModule ...       │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│  Slang (C/C++ Headers)                          │
│  slang.h, slang-gfx.h ...                       │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│  SlangBinary (XCFramework)                      │
│  Prebuilt static library (.a)                   │
└─────────────────────────────────────────────────┘
```

---

## ビルド方法

### 簡単な方法（推奨）

XCFramework は GitHub Releases で配布されているので、通常は自分でビルドする必要はありません。

Swift Package として使う場合は、Package.swift が自動的にダウンロードします。

### XCFramework を自分でビルドする場合

Slang を修正したい場合や、最新版を使いたい場合はローカルビルドが必要です。

#### Step 1: リポジトリのクローン

```bash
# サブモジュール付きでクローン
git clone --recursive https://github.com/shivaduke28/shader-slang-swift.git
cd shader-slang-swift

# 既存のリポジトリの場合
git submodule update --init --recursive
```

#### Step 2: ビルド実行

```bash
# 全自動ビルド（初回は 10〜30 分かかります）
make all
```

このコマンドで以下が順番に実行されます：

1. **generators** - ホスト環境用のコード生成ツールをビルド
2. **device** - iOS Device (arm64) 向けにビルド
3. **simulator** - iOS Simulator (arm64 + x86_64) 向けにビルド
4. **xcframework** - XCFramework を作成
5. **archive** - 配布用 zip と checksum を生成

#### Step 3: 成果物の確認

```bash
# XCFramework が生成されているか確認
ls -la xcframework/

# 出力例:
# SlangCompiler.xcframework/
# SlangCompiler.xcframework.zip
# SlangCompiler.xcframework.zip.checksum
```

### 個別のビルドターゲット

```bash
make help          # ヘルプを表示
make generators    # コード生成ツールのみビルド
make device        # iOS Device 向けのみビルド
make simulator     # iOS Simulator 向けのみビルド
make xcframework   # XCFramework のみ作成
make clean         # ビルド成果物を削除
```

### ビルド時間の目安

| マシン | 初回ビルド | 再ビルド（変更あり） |
|--------|-----------|---------------------|
| M1 MacBook Air | 約 15 分 | 約 3-5 分 |
| Intel MacBook Pro | 約 25-30 分 | 約 5-10 分 |

---

## Swift Package としての使い方

### Xcode プロジェクトへの追加

1. Xcode でプロジェクトを開く
2. File → Add Package Dependencies...
3. URL を入力: `https://github.com/shivaduke28/shader-slang-swift`
4. バージョンを選択して Add Package

### コードでの使用

```swift
import SwiftSlang

// グローバルセッションを作成
guard let globalSession = SLGlobalSession.create() else {
    print("Failed to create global session")
    return
}

// セッション設定を作成
let sessionDesc = SLSessionDesc()

// ターゲットを追加（Metal に出力）
let targetDesc = SLTargetDesc(format: .metal, profile: globalSession.findProfile("metal"))
sessionDesc.targets = [targetDesc]

// セッションを作成
guard let session = globalSession.createSession(with: sessionDesc) else {
    print("Failed to create session")
    return
}

// モジュールをロード
let source = """
[shader("vertex")]
float4 vertexMain(float3 pos : POSITION) : SV_Position
{
    return float4(pos, 1.0);
}
"""

if let module = session.loadModuleFromSource(
    withName: "MyShader",
    path: "MyShader.slang",
    source: source.data(using: .utf8)!
) {
    print("Module loaded: \(module.name)")
}
```

---

## よくある問題と対処法

### CMake 警告: slang-llvm が見つからない

```
CMake Warning at CMakeLists.txt:346 (message):
  Unable to find a prebuilt binary for slang-llvm, Slang will be built
  without LLVM support.
```

**原因**: iOS 向けの slang-llvm プリビルドバイナリが提供されていない

**対処**: **無視して OK** です。LLVM サポートがなくても Metal/SPIRV/HLSL/GLSL へのコンパイルは正常に動作します。

### ビルドエラー: Xcode コマンドラインツールが見つからない

```
xcode-select: error: tool 'xcodebuild' requires Xcode
```

**対処**:

```bash
# Xcode のパスを設定
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### ビルドエラー: CMake のバージョンが古い

```
CMake 3.26 or higher is required.
```

**対処**:

```bash
brew upgrade cmake
```

### ビルドエラー: ディスク容量不足

Slang のビルドには約 2GB の空き容量が必要です。

```bash
# ディスク使用量を確認
df -h

# 不要なビルドキャッシュを削除
make clean
```

### Swift Package のダウンロードが失敗する

**対処**:

1. Xcode の Derived Data を削除
2. Package.resolved を削除して再取得

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
rm Package.resolved
```

---

## 開発フロー

### SwiftSlang のコードを変更した場合

SwiftSlang（`Sources/SwiftSlang/`）のコードを変更した場合：

```bash
# Swift Package として再ビルド
swift build
```

Xcode を使っている場合は、プロジェクトを再ビルドするだけで OK です。

### Slang ヘッダーを更新した場合

`Sources/Slang/include/` のヘッダーを更新した場合：

```bash
# Swift Package として再ビルド
swift build
```

### XCFramework を更新した場合

新しい XCFramework をリリースする場合：

1. `make all` で XCFramework をビルド
2. `xcframework/SlangCompiler.xcframework.zip` を GitHub Releases にアップロード
3. `Package.swift` の checksum を更新

```bash
# checksum を確認
cat xcframework/SlangCompiler.xcframework.zip.checksum
```

### Slang 本体を更新した場合

Slang のバージョンを上げる場合：

```bash
# slang サブモジュールを更新
cd slang
git fetch --tags
git checkout v2025.xx  # 新しいバージョン
cd ..

# 再ビルド
make clean
make all
```

---

## 参考リンク

- [Slang 公式リポジトリ](https://github.com/shader-slang/slang)
- [Slang ドキュメント](https://shader-slang.com/slang/user-guide/)
- [Swift Package Manager](https://swift.org/package-manager/)
