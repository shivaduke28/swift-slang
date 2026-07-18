---
name: create-release
description: SwiftSlang の新しいバージョンをリリースする。GitHub Actions の workflow_dispatch をトリガーする。
argument-hint: [version]
---

# SwiftSlang リリース作成

バージョン: $ARGUMENTS

## 手順

1. **バージョン確認**: `$ARGUMENTS` がセマンティックバージョニング (X.Y.Z) に従っているか確認する

2. **最新リリースバージョンの確認**: リリースタグは GitHub Actions が作成し main には乗らないため、ローカルのタグは古いことがある。必ずリモートを確認する:
   - `git fetch --tags` でタグを同期する
   - `gh release list --limit 10 | grep -v slang-binary` で最新のパッケージリリース (vX.Y.Z) を確認する（`slang-binary/*` はバイナリ専用リリースなので除外する）
   - ローカルの `git describe` だけで判断しないこと（古いバージョンを提案してタグ重複でワークフローが失敗する）

3. **リリース内容の確認**: 前回リリースからの変更を確認する
   - リリースタグは main に乗らないので、`git log $(git merge-base <最新タグ> HEAD)..HEAD --oneline` で差分コミットを確認
   - 変更内容をユーザーに提示して確認を取る

4. **未コミットの変更確認**: `git status` でコミット漏れがないか確認する。未コミットの変更がある場合はユーザーに警告する

5. **mainにpush済みか確認**: `git log origin/main..HEAD --oneline` でpush されていないコミットがないか確認する。あればユーザーに警告する

6. **GitHub Actions トリガー**: 以下のコマンドでリリースワークフローを実行する
   ```
   gh workflow run release.yml -f version=$ARGUMENTS
   ```

7. **ワークフローの監視**: 実行状況を確認する
   ```
   gh run list --workflow=release.yml --limit=1
   ```

8. **結果の報告**: リリースURLをユーザーに報告する

## 注意事項

- Slang バイナリの更新が必要な場合は、先に `/update-slang` を実行すること
- mainブランチから実行すること
- コミットメッセージ・リリースノートにキャラ口調を使わないこと
