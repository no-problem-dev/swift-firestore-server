# ドキュメント操作

FirestoreClientを使用したCRUD操作です。

## クライアントの初期化

```swift
import FirestoreServer

// Cloud Run / ローカル gcloud（自動検出）
let client = try await FirestoreClient(.auto)

// カスタムデータベースID
let client = try await FirestoreClient(.autoWithDatabase(databaseId: "custom-db"))

// エミュレーター
let client = FirestoreClient(.emulator(projectId: "demo-project"))

// 明示指定
let client = FirestoreClient(.explicit(projectId: "my-project", token: accessToken))
```

## 参照の取得

```swift
// コレクション参照
let usersRef = client.collection("users")

// ドキュメント参照（パス直接指定）
let userRef = try client.document("users/user123")

// スキーマを使用（FirestoreSchemaと併用）
let userRef = try client.document(Schema.Users.documentPath("user123"))
let postsRef = client.collection(Schema.Users.Posts.collectionPath("user123"))
```

## 取得（Read）

```swift
// 型指定で取得
let user: User = try await client.getDocument(userRef, as: User.self)

// 生のFirestoreDocumentとして取得
let document = try await client.getDocument(userRef)
```

## 作成（Create）

```swift
// Encodableオブジェクトを作成
try await client.createDocument(userRef, data: newUser)

// フィールドを直接指定
try await client.createDocument(
    userRef,
    fields: [
        "name": .string("田中太郎"),
        "age": .integer(30)
    ]
)
```

## 更新（Update）

```swift
// Encodableオブジェクトで更新
try await client.updateDocument(userRef, data: updatedUser)

// フィールドを直接指定
try await client.updateDocument(
    userRef,
    fields: ["displayName": .string("新しい名前")]
)
```

## 削除（Delete）

```swift
try await client.deleteDocument(userRef)
```

## 一覧取得

```swift
// 型指定で一覧取得
let (users, nextPageToken) = try await client.listDocuments(
    in: usersRef,
    as: User.self,
    pageSize: 20
)

// 次のページを取得
if let token = nextPageToken {
    let (moreUsers, _) = try await client.listDocuments(
        in: usersRef,
        as: User.self,
        pageSize: 20,
        pageToken: token
    )
}
```

## エラーハンドリング

```swift
do {
    let user: User = try await client.getDocument(userRef, as: User.self)
} catch let error as FirestoreError {
    switch error {
    case .api(let apiError):
        // APIエラー（notFound, permissionDenied, unauthenticated等）
        print(apiError)
    case .decoding(let underlying):
        // デコードエラー
        print(underlying)
    case .encoding(let underlying):
        // エンコードエラー
        print(underlying)
    }
}
```

## 関連ドキュメント

- [クエリ](queries.md) - フィルター、ソート、ページネーション
