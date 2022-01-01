import Foundation
import HTML

struct XMLEncodingFilter: Filter {
    static func encode(@NodeBuilder content: () -> NodeConvertible) -> Node {
        .element("custom-xml-encode", [:], content().asNode())
    }

    func apply(node: Node, resources: inout Set<Resource>) -> Node {
        let visitor = XMLEncodingVisitor()

        return visitor.visitNode(node)
    }
}

private final class XMLEncodingVisitor: Visitor {
    func visitElement(name: String, attributes: [String : String], child: Node?) -> Node {
        guard name == "custom-xml-encode" else {
            return .element(name, attributes, child.map(visitNode))
        }

        let string = String(describing: child ?? .trim)
            .trimmingCharacters(in: .whitespaces)
            .addingXMLEncoding()

        return .raw(string)
    }
}
