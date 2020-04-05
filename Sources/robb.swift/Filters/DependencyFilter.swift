import Foundation
import HTML

/// Injects a dependency into the `head` of the current page, if it exists.
struct DependencyFilter: Filter {
    func apply(node: Node, resources: inout Set<Resource>) -> Node {
        let finder = DependencyFindingVisitor()

        let stripped = finder.visitNode(node)

        let injector = DependencyInjectingVisitor(nodesToInject: finder.nodesToInject)

        return injector.visitNode(stripped)
    }

    static func dependency(javascript path: String, async: Bool) -> Node {
        var attributes = [ "src": path ]

        attributes["async"] = async ? "" : nil

        return Node.element("custom-script-dependency", attributes, nil)
    }

    static func dependency(stylesheet path: String) -> Node {
        return Node.element("custom-stylesheet-dependency", [ "href": path, "rel": "stylesheet" ], nil)
    }
}

private final class DependencyFindingVisitor: Visitor {
    var nodesToInject: [Node] = []

    func visitElement(name: String, attributes: [String : String], child: Node?) -> Node {
        if name == "custom-script-dependency" {
            let dependency = Node.element("script", attributes, [])

            if !nodesToInject.contains(dependency) {
                nodesToInject.append(dependency)
            }

            return []
        }

        if name == "custom-stylesheet-dependency" {
            let dependency = Node.element("link", attributes, nil)

            if !nodesToInject.contains(dependency) {
                nodesToInject.append(dependency)
            }

            return []
        }

        return .element(name, attributes, child.map(visitNode))
    }
}

private final class DependencyInjectingVisitor: Visitor {
    var nodesToInject: [Node]

    init(nodesToInject: [Node]) {
        self.nodesToInject = nodesToInject
    }

    func visitElement(name: String, attributes: [String : String], child: Node?) -> Node {
        if name == "head" {
            var nodes = nodesToInject

            if let child = child {
                nodes.insert(child, at: 0)
            }

            return .element(name, attributes, .fragment(nodes))
        }

        return .element(name, attributes, child.map(visitNode))
    }
}
