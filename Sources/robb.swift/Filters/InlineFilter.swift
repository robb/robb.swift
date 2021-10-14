import Foundation
import HTML

struct InlineFilter: Filter {
    var baseURL: URL

    func apply(node: Node, resources: inout Set<Resource>) -> Node {
        let visitor = InlineFilterVisitor(baseURL: baseURL)

        return visitor.visitNode(node)
    }

    static func inline(file path: String) -> Node {
        Node.element("custom-inline", [ "path": path ], [])
    }
}

private final class InlineFilterVisitor: Visitor {
    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func visitElement(name: String, attributes: [String : String], child: Node?) -> Node {
        guard name == "custom-inline", let path = attributes["path"] else {
            return .element(name, attributes, child.map(visitNode))
        }

        let url = URL(fileURLWithPath: path, relativeTo: baseURL)

        return try! .raw(String(contentsOf: url))
    }
}
