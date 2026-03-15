# SwiftSlang Development Notes

## Build & Test

```bash
# Build
swift build

# Test (iOS Simulator required)
xcodebuild test \
  -scheme SwiftSlang-Package \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -skipPackagePluginValidation
```

## Metal Target Specifics

- `uniform MyStruct params;` のようなstruct uniformは、Metal ターゲットでは `SLParameterCategory.uniform` カテゴリになる（`constantBuffer` ではない）
- `param.typeLayout` で直接 struct の `SLTypeLayout` が取れる（ConstantBuffer の `elementTypeLayout` 経由ではない）

## User Attributes

- Slang の user attribute 宣言には `[__AttributeUsage(_AttributeTargets.Var)]` 構文を使う
- struct 名は小文字始まり（例: `rangeAttribute`）、使用時も小文字（例: `[range(0.0, 0.5, 1.0)]`）

## Object Lifetime

- `SLGlobalSession` は `SLSession` より長く生存させる必要がある。`SLGlobalSession` が先に解放されると、セッション系 API がクラッシュする
- テストでは各テストメソッド内で `SLGlobalSession` をローカル変数として保持し、メソッドスコープの最後まで生存させること
