import Foundation

// MARK: - FilterBuilder

/// フィルター条件を構築するためのResultBuilder
///
/// 複数のフィルター条件を宣言的に記述できます。
/// デフォルトでは複数の条件はAND結合されます。
///
/// ## 基本的な使用例
///
/// ```swift
/// query.filter {
///     Field("status") == "active"
///     Field("age") >= 18
/// }
/// // → status == "active" AND age >= 18
/// ```
///
/// ## 条件分岐
///
/// ```swift
/// query.filter {
///     Field("status") == "active"
///     if onlyPublished {
///         Field("published") == true
///     }
/// }
/// ```
///
/// ## 論理グループ化
///
/// ```swift
/// query.filter {
///     And {
///         Field("status") == "active"
///         Field("verified") == true
///     }
///     Or {
///         Field("role") == "admin"
///         Field("role") == "moderator"
///     }
/// }
/// ```
@resultBuilder
public struct FilterBuilder {
    /// 単一フィルターをそのまま返す
    public static func buildExpression(_ filter: FieldFilter) -> [any QueryFilterProtocol] {
        [filter]
    }

    /// 単一UnaryFilterをそのまま返す
    public static func buildExpression(_ filter: UnaryFilter) -> [any QueryFilterProtocol] {
        [filter]
    }

    /// CompositeFilterをそのまま返す
    public static func buildExpression(_ filter: CompositeFilter) -> [any QueryFilterProtocol] {
        [filter]
    }

    /// QueryFilterをそのまま返す
    public static func buildExpression(_ filter: QueryFilter) -> [any QueryFilterProtocol] {
        [filter]
    }

    /// And構造体から生成されたCompositeFilterを返す
    public static func buildExpression(_ and: And) -> [any QueryFilterProtocol] {
        [and.filter]
    }

    /// Or構造体から生成されたCompositeFilterを返す
    public static func buildExpression(_ or: Or) -> [any QueryFilterProtocol] {
        [or.filter]
    }

    /// 複数のフィルター配列を結合
    public static func buildBlock(_ components: [any QueryFilterProtocol]...) -> [any QueryFilterProtocol] {
        components.flatMap { $0 }
    }

    /// 空のブロック
    public static func buildBlock() -> [any QueryFilterProtocol] {
        []
    }

    /// Optional展開（if let）
    public static func buildOptional(_ component: [any QueryFilterProtocol]?) -> [any QueryFilterProtocol] {
        component ?? []
    }

    /// if-else の true 分岐
    public static func buildEither(first component: [any QueryFilterProtocol]) -> [any QueryFilterProtocol] {
        component
    }

    /// if-else の false 分岐
    public static func buildEither(second component: [any QueryFilterProtocol]) -> [any QueryFilterProtocol] {
        component
    }

    /// for-in ループ
    public static func buildArray(_ components: [[any QueryFilterProtocol]]) -> [any QueryFilterProtocol] {
        components.flatMap { $0 }
    }

    /// #available などの可用性チェック
    public static func buildLimitedAvailability(_ component: [any QueryFilterProtocol]) -> [any QueryFilterProtocol] {
        component
    }

    /// 最終結果を構築
    ///
    /// トップレベルでは単一のフィルターのみ許可。
    /// 複数条件を組み合わせる場合は明示的に`And`または`Or`で囲む必要があります。
    public static func buildFinalResult(_ component: [any QueryFilterProtocol]) -> QueryFilter {
        switch component.count {
        case 0:
            fatalError("FilterBuilder requires at least one filter condition")
        case 1:
            return QueryFilter(component[0])
        default:
            fatalError("Multiple filters at top level are not allowed. Use And { } or Or { } to combine filters explicitly.")
        }
    }
}

// MARK: - And Grouping

/// AND条件をグループ化するための構造体
///
/// FilterBuilder内で明示的にANDグループを作成します。
///
/// ```swift
/// query.filter {
///     And {
///         Field("status") == "active"
///         Field("verified") == true
///     }
/// }
/// ```
public struct And: Sendable {
    /// 内部のCompositeFilter
    public let filter: CompositeFilter

    /// AND条件を構築
    /// - Parameter content: フィルター条件を生成するクロージャ
    public init(@AndFilterBuilder content: () -> [any QueryFilterProtocol]) {
        let filters = content()
        self.filter = CompositeFilter(
            op: .and,
            filters: filters.map { QueryFilter($0) }
        )
    }
}

/// And専用のResultBuilder（常にフィルター配列を返す）
@resultBuilder
public struct AndFilterBuilder {
    public static func buildExpression(_ filter: FieldFilter) -> [any QueryFilterProtocol] {
        [filter]
    }

    public static func buildExpression(_ filter: UnaryFilter) -> [any QueryFilterProtocol] {
        [filter]
    }

    public static func buildExpression(_ filter: CompositeFilter) -> [any QueryFilterProtocol] {
        [filter]
    }

    public static func buildExpression(_ and: And) -> [any QueryFilterProtocol] {
        [and.filter]
    }

    public static func buildExpression(_ or: Or) -> [any QueryFilterProtocol] {
        [or.filter]
    }

    public static func buildBlock(_ components: [any QueryFilterProtocol]...) -> [any QueryFilterProtocol] {
        components.flatMap { $0 }
    }

    public static func buildBlock() -> [any QueryFilterProtocol] {
        []
    }

    public static func buildOptional(_ component: [any QueryFilterProtocol]?) -> [any QueryFilterProtocol] {
        component ?? []
    }

    public static func buildEither(first component: [any QueryFilterProtocol]) -> [any QueryFilterProtocol] {
        component
    }

    public static func buildEither(second component: [any QueryFilterProtocol]) -> [any QueryFilterProtocol] {
        component
    }

    public static func buildArray(_ components: [[any QueryFilterProtocol]]) -> [any QueryFilterProtocol] {
        components.flatMap { $0 }
    }
}

// MARK: - Or Grouping

/// OR条件をグループ化するための構造体
///
/// FilterBuilder内で明示的にORグループを作成します。
///
/// ```swift
/// query.filter {
///     Or {
///         Field("role") == "admin"
///         Field("role") == "moderator"
///     }
/// }
/// ```
public struct Or: Sendable {
    /// 内部のCompositeFilter
    public let filter: CompositeFilter

    /// OR条件を構築
    /// - Parameter content: フィルター条件を生成するクロージャ
    public init(@OrFilterBuilder content: () -> [any QueryFilterProtocol]) {
        let filters = content()
        self.filter = CompositeFilter(
            op: .or,
            filters: filters.map { QueryFilter($0) }
        )
    }
}

/// Or専用のResultBuilder（常にフィルター配列を返す）
@resultBuilder
public struct OrFilterBuilder {
    public static func buildExpression(_ filter: FieldFilter) -> [any QueryFilterProtocol] {
        [filter]
    }

    public static func buildExpression(_ filter: UnaryFilter) -> [any QueryFilterProtocol] {
        [filter]
    }

    public static func buildExpression(_ filter: CompositeFilter) -> [any QueryFilterProtocol] {
        [filter]
    }

    public static func buildExpression(_ and: And) -> [any QueryFilterProtocol] {
        [and.filter]
    }

    public static func buildExpression(_ or: Or) -> [any QueryFilterProtocol] {
        [or.filter]
    }

    public static func buildBlock(_ components: [any QueryFilterProtocol]...) -> [any QueryFilterProtocol] {
        components.flatMap { $0 }
    }

    public static func buildBlock() -> [any QueryFilterProtocol] {
        []
    }

    public static func buildOptional(_ component: [any QueryFilterProtocol]?) -> [any QueryFilterProtocol] {
        component ?? []
    }

    public static func buildEither(first component: [any QueryFilterProtocol]) -> [any QueryFilterProtocol] {
        component
    }

    public static func buildEither(second component: [any QueryFilterProtocol]) -> [any QueryFilterProtocol] {
        component
    }

    public static func buildArray(_ components: [[any QueryFilterProtocol]]) -> [any QueryFilterProtocol] {
        components.flatMap { $0 }
    }
}

// MARK: - Query Extension

extension Query {
    /// FilterBuilder DSLを使用してフィルター条件を追加
    ///
    /// トップレベルでは単一のフィルターのみ許可されます。
    /// 複数条件を組み合わせる場合は明示的に`And`または`Or`で囲む必要があります。
    ///
    /// ## 使用例
    ///
    /// ```swift
    /// // 単一条件のフィルタリング
    /// let activeUsers = try await schema.users
    ///     .query(as: User.self)
    ///     .filter {
    ///         Field("status") == "active"
    ///     }
    ///     .get()
    ///
    /// // 複数条件（明示的なAnd）
    /// let users = try await schema.users
    ///     .query(as: User.self)
    ///     .filter {
    ///         And {
    ///             Field("status") == "active"
    ///             Field("age") >= 18
    ///             if onlyVerified {
    ///                 Field("verified") == true
    ///             }
    ///         }
    ///     }
    ///     .get()
    ///
    /// // OR条件
    /// let admins = try await schema.users
    ///     .query(as: User.self)
    ///     .filter {
    ///         Or {
    ///             Field("role") == "admin"
    ///             Field("role") == "moderator"
    ///         }
    ///     }
    ///     .get()
    ///
    /// // ネストした条件
    /// let products = try await schema.products
    ///     .query(as: Product.self)
    ///     .filter {
    ///         And {
    ///             Field("active") == true
    ///             Field("stock") > 0
    ///             Or {
    ///                 Field("category") == "electronics"
    ///                 Field("featured") == true
    ///             }
    ///         }
    ///     }
    ///     .get()
    /// ```
    ///
    /// - Parameter content: フィルター条件を構築するクロージャ
    /// - Returns: フィルターが追加された新しいQueryインスタンス
    public func filter(@FilterBuilder _ content: () -> QueryFilter) -> Query<T> {
        let queryFilter = content()
        return self.where(queryFilter)
    }
}
