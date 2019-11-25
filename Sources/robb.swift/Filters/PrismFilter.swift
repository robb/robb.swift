import Foundation
import HTML

/// Automatically sets up a dependency to prism.js for every `code` element has
/// a `language-xxx` class
struct PrismFilter: Filter {
    func apply(node: Node) -> Node {
        let visitor = PrismVisitor()

        return visitor.visitNode(node)
    }
}

private final class PrismVisitor: Visitor {
    func visitElement(name: String, attributes: [String: String], child: Node?) -> Node {
        guard name == "code" && attributes.hasLanguageClass else {
            return .element(name: name, attributes: attributes, child: child.map(visitNode))
        }

        return .element(name: name, attributes: attributes, child: [
            DependencyFilter.dependency(javascript: "/js/prism.js", async: true),
            DependencyFilter.dependency(stylesheet: "/css/prism.css"),
            child.map(visitNode) ?? []
        ])
    }
}

extension Dictionary where Key == String, Value == String {
    var hasLanguageClass: Bool {
        self["class"]?
            .split(separator: " ")
            .contains { $0.hasPrefix("language-") } ?? false
    }
}
