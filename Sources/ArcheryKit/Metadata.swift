public enum Metadata: Codable, Equatable {
    case boolean(Bool)
    case string(String)
    case number(Decimal)
    case null
    case array([Metadata])
    case dictionary([String: Metadata])

    public init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer() {
            if let bool = try? single.decode(Bool.self) {
                self = .boolean(bool)
            } else if let value = try? single.decode(String.self) {
                self = .string(value)
            } else if let value = try? single.decode(Decimal.self) {
                self = .number(value)
            } else if single.decodeNil() {
                self = .null
            } else if let value = try? single.decode([Metadata].self) {
                self = .array(value)
            } else {
                let value = try single.decode([String: Metadata].self)
                self = .dictionary(value)
            }
        } else {
            fatalError("This should never be called.")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .array(value):
            try container.encode(value)
        case let .dictionary(value):
            try container.encode(value)
        case let .number(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        case let .boolean(value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

public extension Metadata {
    public func asJSON() -> Any? {
        switch self {
        case let .dictionary(dict):
            return dict.mapValues { $0.asJSON() }
        case let .array(value):
            return value.map { $0.asJSON() }
        case let .boolean(value):
            return value
        case let .string(value):
            return value
        case let .number(value):
            return value
        case .null:
            return nil
        }
    }

    public func asJSONDictionary() -> [String: Any]? {
        guard case let .dictionary(dict) = self else {
            return nil
        }
        let entries = dict.compactMap { pair in
            return pair.value.asJSON().map { value in (pair.key, value) }
        }
        return Dictionary(entries, uniquingKeysWith: { $1 })
    }
}

public extension Metadata {
    public func overriding(using right: Metadata) -> Metadata {
        switch (self, right) {
        case let (.array(l), .array(r)):
            return .array(l + r)
        case let (.dictionary(l), .dictionary(r)):
            return .dictionary(l.merging(r, uniquingKeysWith: { lhs, rhs in lhs.overriding(using: rhs) }))
        case _:
            return right
        }
    }
}

public extension Metadata {
    public subscript(_ key: String) -> Metadata? {
        guard case let .dictionary(dict) = self else {
            return nil
        }
        return dict[key]
    }

    public subscript(_ index: Int) -> Metadata? {
        guard case let .array(dict) = self else {
            return nil
        }
        return dict[index]
    }
}

public extension Metadata {
    public init(json: Any) {
        if let value = json as? Metadata {
            self = value
        } else if let value = json as? String {
            self = .string(value)
        } else if let value = json as? Bool {
            self = .boolean(value)
        } else if let value = json as? Decimal {
            self = .number(value)
        } else if let value = json as? Int {
            self = .number(Decimal(value))
        } else if let value = json as? Double {
            self = .number(Decimal(value))
        } else if let value = json as? Float {
            self = .number(Decimal(Double(value)))
        } else if let value = json as? [String: Any] {
            self = .dictionary(value.mapValues(Metadata.init(json:)))
        } else if let value = json as? [Any] {
            self = .array(value.map(Metadata.init(json:)))
        } else {
            self = .null
        }
    }
}

import Yams

public extension Metadata {
    public init(string: String) throws {
        self = try Yams.YAMLDecoder().decode(Metadata.self, from: string)
    }
}

import Foundation

extension Annotated where V == Metadata {
    public init(metadata: Metadata) throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let archerfile = try decoder.decode(V.self, from: encoder.encode(metadata))
        self.init(value: archerfile, by: metadata)
    }
}
