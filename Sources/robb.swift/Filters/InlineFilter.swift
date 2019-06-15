import Foundation
import HTML

struct InlineFilter: Filter {
    var baseURL: URL

    func apply(node: Node) -> [Node] {
        if let node = node as? Tag, node.name == "custom-inline", let path = node.attributes["path"] {
            let url = URL(fileURLWithPath: path, relativeTo: baseURL)

            return try! [ Text(value: String(contentsOf: url)) ]
        }

        return [ node ]
    }

    static func inline(file path: String) -> Node {
        Tag(name: "custom-inline", attributes: [ "path": path ], children: [])
    }
}
