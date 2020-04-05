import Foundation
import HTML

/// Automatically sets up a dependency to prism.js for every `figure` element
/// that has a `highlight` class
struct PrismFilter: Filter {
    func apply(node: Node, resources: inout Set<Resource>) -> Node {
        let visitor = PrismVisitor()

        return visitor.visitNode(node)
    }
}

private final class PrismVisitor: Visitor {
    func visitElement(name: String, attributes: [String: String], child: Node?) -> Node {
        guard name == "figure" && attributes.hasHighlightClass else {
            return .element(name, attributes, child.map(visitNode))
        }

        return .element(name, attributes, [
            DependencyFilter.dependency(javascript: "/js/prism.js", async: true),
            DependencyFilter.dependency(stylesheet: "/css/prism.css"),
            child.map(visitNode) ?? []
        ])
    }
}

private extension Dictionary where Key == String, Value == String {
    var hasHighlightClass: Bool {
        self["class"]?
            .split(separator: " ")
            .contains("highlight") ?? false
    }
}
