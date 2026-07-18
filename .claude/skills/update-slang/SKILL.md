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

**重要**: コピー後、各ヘッダーファイルの先頭にライセンスヘッダーが残っているか確認する。元のファイルにある以下のブロックが消えていたら復元すること:

```c
/*
 * Slang
 * https://github.com/shader-slang/slang
 * Copyright (c) 2017 Slang Contributors
 *
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
 *
 * See LICENSE.txt in this directory for the full license text.
 */
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

**新しい依存ライブラリの確認**: Slang は更新で外部依存を増やすことがある（例: v2026.13.1 で cmark-gfm が追加された）。ビルドツリーに Makefile が知らない静的ライブラリがないか確認する:

```bash
find slang/build-ios-device -name "*.a" | grep -v "Release/lib"
```

既知の miniz / lz4 / cmark-gfm は必ず表示されるので無視してよい。それ以外の `.a` が出てきたら、Makefile の3プラットフォーム分の strip・cp・libtool マージ対象に追加してからビルドし直すこと。マージ漏れがあるとテストのリンク時に undefined symbols で失敗する。

**ビルドのトラブルシューティング**:
- iOS の configure が `install TARGETS given no BUNDLE DESTINATION` で失敗する場合: 新しい実行ファイルターゲットが原因。iOS では実行ファイルが自動でバンドル扱いになるため。Makefile の iOS 向け cmake 呼び出しには `-DCMAKE_MACOSX_BUNDLE=NO` を渡して回避している（v2026.13.1 の slang-dispatcher で発生）

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

### 6. テスト実行

Package.swift 更新後、必ずテストを実行してリンクエラーがないか確認する（binaryTarget はリモート URL 参照のため、リリース作成後でないとテストできない）:

```bash
xcodebuild test \
  -scheme SwiftSlang-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -skipPackagePluginValidation
```

- テスト結果は `Executed N tests, with 0 failures` と `** TEST SUCCEEDED **` まで確認すること。destination が存在しないと候補一覧を出して終了するだけで、パイプの仕方によっては exit code 0 に見えることがある
- リンクエラーが出た場合はバイナリを修正して再ビルドし、`gh release upload "slang-binary/<version>" xcframework/SlangBinary.xcframework.zip --clobber` で差し替え、Package.swift の checksum も更新する
- バイナリ差し替え後に checksum 不一致エラーが出たら、SwiftPM が古い zip をキャッシュしている。`rm -rf ~/Library/Caches/org.swift.swiftpm` と DerivedData の削除で解消する

### 7. README.md 更新

README.md の Slang バージョン表記を更新する。

### 8. コミット

変更をコミットする（コミットメッセージにキャラ口調を使わないこと）:

```
Update Slang to $ARGUMENTS
```

## 注意事項

- ビルドは Apple Silicon Mac で実行すること
- mainブランチで作業すること
- ビルド成果物 (build/, xcframework/) は .gitignore されている
- コミット後、`/create-release` でパッケージリリースを作成できる
