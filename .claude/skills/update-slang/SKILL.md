---
name: update-slang
description: Slang のバージョンを更新し、XCFramework をビルドしてバイナリリリースを作成する。ローカルでのビルドが必要。
argument-hint: [slang-version]
---

# Slang 更新

更新先バージョン: $ARGUMENTS (例: v2025.22)

## 前提条件の確認

以下のツールがインストールされているか確認する:
- cmake (3.26以上)
- ninja (1.11以上)
- Xcode Command Line Tools

```
cmake --version && ninja --version && xcodebuild -version
```

## 手順

### 1. サブモジュール更新

```bash
git submodule update --init --recursive
cd slang
git fetch --tags
git checkout $ARGUMENTS
cd ..
```

### 2. ヘッダーファイルの更新

slang サブモジュールから最新ヘッダーを `Sources/Slang/include/` にコピーする:

```bash
cp slang/include/slang.h Sources/Slang/include/
cp slang/include/slang-com-ptr.h Sources/Slang/include/
cp slang/include/slang-com-helper.h Sources/Slang/include/
```

ヘッダーに差分があるか `git diff` で確認し、API の破壊的変更がないかユーザーに報告する。

### 3. XCFramework ビルド

```bash
make clean
make all
```

ビルドには 10〜30 分かかる。ビルド完了後、成果物を確認:

```bash
make verify
cat xcframework/SlangBinary.xcframework.zip.checksum
```

### 4. バイナリリリース作成

Slang バイナリ専用のリリースを作成する。タグ形式は `slang-binary/$ARGUMENTS`:

```bash
gh release create "slang-binary/$ARGUMENTS" \
  xcframework/SlangBinary.xcframework.zip \
  --title "Slang Binary $ARGUMENTS" \
  --notes "Slang $ARGUMENTS のプリビルド XCFramework (iOS Device + Simulator)"
```

### 5. Package.swift 更新

`Package.swift` の `binaryTarget` を更新する:
- `url`: 新しいリリースの URL に変更
- `checksum`: 新しい checksum に変更

```swift
.binaryTarget(
    name: "SlangBinary",
    url: "https://github.com/shivaduke28/swift-slang/releases/download/slang-binary/$ARGUMENTS/SlangBinary.xcframework.zip",
    checksum: "<checksumファイルの値>"
),
```

### 6. README.md 更新

README.md の Slang バージョン表記を更新する。

### 7. コミット

変更をコミットする（コミットメッセージにキャラ口調を使わないこと）:

```
Update Slang to $ARGUMENTS
```

## 注意事項

- ビルドは Apple Silicon Mac で実行すること
- mainブランチで作業すること
- ビルド成果物 (build/, xcframework/) は .gitignore されている
- コミット後、`/create-release` でパッケージリリースを作成できる
