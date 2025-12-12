# クイックスタート

5分でswift-firebase-serverをセットアップします。

## インストール

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-firebase-server.git", .upToNextMajor(from: "1.0.0"))
]

.target(
    name: "YourApp",
    dependencies: [
        .product(name: "FirestoreServer", package: "swift-firebase-server"),
        .product(name: "FirestoreSchema", package: "swift-firebase-server"),
    ]
)
```

## 最小構成例

```swift
import FirestoreServer
import FirestoreSchema

// 1. モデルを定義
@FirestoreModel(keyStrategy: .snakeCase)
struct User {
    let userId: String
    let displayName: String
    let email: String
}

// 2. スキーマを定義
@FirestoreSchema
enum Schema {
    @Collection("users", model: User.self)
    enum Users {}
}

// 3. クライアントを初期化
let client = try await FirestoreClient(.auto)

// 4. ドキュメントを操作
let docRef = client.document(Schema.Users.documentPath("user123"))
let user: User = try await client.getDocument(docRef, as: User.self)
```

## 環境別の初期化

```swift
// Cloud Run / ローカル gcloud（自動検出）
let client = try await FirestoreClient(.auto)

// カスタムデータベースID
let client = try await FirestoreClient(.autoWithDatabase(databaseId: "custom-db"))

// エミュレーター
let client = FirestoreClient(.emulator(projectId: "demo-project"))

// 明示指定（テスト等）
let client = FirestoreClient(.explicit(projectId: "my-project", token: accessToken))
```

## 要件

- macOS 14+
- Swift 6.2+
- Xcode 16+

## 次のステップ

- [スキーマ定義](firestore/schema-definition.md) - コレクション構造の定義方法
- [モデル定義](firestore/model-definition.md) - Firestoreモデルの定義方法
- [ドキュメント操作](firestore/document-operations.md) - CRUD操作の詳細
