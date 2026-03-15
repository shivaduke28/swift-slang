---
name: create-release
description: SwiftSlang の新しいバージョンをリリースする。GitHub Actions の workflow_dispatch をトリガーする。
argument-hint: [version]
---

# SwiftSlang リリース作成

バージョン: $ARGUMENTS

## 手順

1. **バージョン確認**: `$ARGUMENTS` がセマンティックバージョニング (X.Y.Z) に従っているか確認する

2. **リリース内容の確認**: 前回リリースからの変更を確認する
   - `git log $(git describe --tags --abbrev=0)..HEAD --oneline` で差分コミットを確認
   - 変更内容をユーザーに提示して確認を取る

3. **未コミットの変更確認**: `git status` でコミット漏れがないか確認する。未コミットの変更がある場合はユーザーに警告する

4. **mainにpush済みか確認**: `git log origin/main..HEAD --oneline` でpush されていないコミットがないか確認する。あればユーザーに警告する

5. **GitHub Actions トリガー**: 以下のコマンドでリリースワークフローを実行する
   ```
   gh workflow run release.yml -f version=$ARGUMENTS
   ```

6. **ワークフローの監視**: 実行状況を確認する
   ```
   gh run list --workflow=release.yml --limit=1
   ```

7. **結果の報告**: リリースURLをユーザーに報告する

## 注意事項

- Slang バイナリの更新が必要な場合は、先に `/update-slang` を実行すること
- mainブランチから実行すること
- コミットメッセージ・リリースノートにキャラ口調を使わないこと
