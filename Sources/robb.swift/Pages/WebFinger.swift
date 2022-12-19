import Foundation
import Swim

struct WebFinger: Page {
    static let defaultLayout: Layout = .empty

    let contentType = "application/json"

    let pathComponents = [ ".well-known", "webfinger" ]

    let title = "Webfinger"

    func content() -> Node {
        let webfinger = JSON.object([
            "subject": .string("acct:dlx@mastodon.social"),
            "aliases": .array([
                .string("https://mastodon.social/@dlx"),
                .string("https://mastodon.social/users/dlx")
            ]),
            "links": .array([
                .object([
                    "rel":  .string("http://webfinger.net/rel/profile-page"),
                    "type": .string("text/html"),
                    "href": .string("https://mastodon.social/@dlx"),
                ]),
                .object([
                    "rel":  .string("self"),
                    "type": .string("application/activity+json"),
                    "href": .string("https://mastodon.social/users/dlx"),
                ]),
                .object([
                    "rel":  .string("http://ostatus.org/schema/1.0/subscribe"),
                    "href": .string("https://mastodon.social/authorize_interaction?uri={uri}"),
                ]),
            ])
        ])

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

        let data = try! encoder.encode(webfinger)

        return .raw(String(data: data, encoding: .utf8)!)
    }
}

private enum JSON: Hashable, Codable {
    case object([String: JSON])
    case array([JSON])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    public init(from decoder: Decoder) throws {
            if let container = try? decoder.container(keyedBy: JSONCodingKeys.self) {
                self = try JSON(container: container)
            } else if var container = try? decoder.unkeyedContainer() {
                self = try JSON(container: &container)
            } else if let container = try? decoder.singleValueContainer() {
                if let bool = try? container.decode(Bool.self) {
                    self = .bool(bool)
                } else if let number = try? container.decode(Double.self) {
                    self = .number(number)
                } else if let string = try? container.decode(String.self) {
                    self = .string(string)
                } else if container.decodeNil() {
                    self = .null
                } else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: ""))
                }
            }
            else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: ""))
            }
        }

        private init(container: KeyedDecodingContainer<JSONCodingKeys>) throws {
            let values = try container.allKeys.map { codingKey -> JSON in
                try container.decode(JSON.self, forKey: codingKey)
            }

            let zipped = zip(container.allKeys.map(\.stringValue), values)

            self = .object(Dictionary(zipped) { a, _ in a })
        }

        private init(container: inout UnkeyedDecodingContainer) throws {
            var values: [JSON] = []

            while !container.isAtEnd {
                values.append(try container.decode(JSON.self))
            }

            self = .array(values)
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .object(let object):
                var container = encoder.container(keyedBy: JSONCodingKeys.self)

                for (key, value) in object {
                    let codingKey = JSONCodingKeys(stringValue: key)!

                    try container.encode(value, forKey: codingKey)
                }
            case .array(let array):
                var container = encoder.unkeyedContainer()

                for value in array {
                    try container.encode(value)
                }
            case .string(let string):
                var container = encoder.singleValueContainer()

                try container.encode(string)
            case .number(let number):
                var container = encoder.singleValueContainer()

                try container.encode(number)
            case .bool(let bool):
                var container = encoder.singleValueContainer()

                try container.encode(bool)
            case .null:
                var container = encoder.singleValueContainer()

                try container.encodeNil()
            }
        }
}

fileprivate struct JSONCodingKeys: CodingKey {
    internal var stringValue: String

    internal init?(stringValue: String) {
        self.stringValue = stringValue
    }

    internal var intValue: Int?

    internal init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}
