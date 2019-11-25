import Foundation
import HTML

/// Injects a dependency into the `head` of the current page, if it exists.
struct DependencyFilter: Filter {
    func apply(node: Node) -> Node {
        let finder = DependencyFindingVisitor()

        let stripped = finder.visitNode(node)

        let injector = DependencyInjectingVisitor(dependencies: finder.dependencies)

        return injector.visitNode(stripped)
    }

    static func dependency(javascript path: String, async: Bool) -> Node {
        var attributes = [ "src": path ]

        attributes["async"] = async ? "async" : nil

        return Node.element(name: "custom-script-dependency", attributes: attributes, child: nil)
    }

    static func dependency(stylesheet path: String) -> Node {
        return Node.element(name: "custom-stylesheet-dependency", attributes: [ "href": path ], child: nil)
    }
}

private enum Dependency: Equatable {
    case script(src: String, async: String?)
    case stylesheet(href: String)
}

private final class DependencyFindingVisitor: Visitor {
    var dependencies: [Dependency] = []

    func visitElement(name: String, attributes: [String : String], child: Node?) -> Node {
        if name == "custom-script-dependency" {
            let dependency = Dependency.script(src: attributes["src"]!, async: attributes["async"])

            if !dependencies.contains(dependency) {
                dependencies.append(dependency)
            }

            return []
        }

        if name == "custom-stylesheet-dependency" {
            let dependency = Dependency.stylesheet(href: attributes["href"]!)

            if !dependencies.contains(dependency) {
                dependencies.append(dependency)
            }

            return []
        }

        return .element(name: name, attributes: attributes, child: child.map(visitNode))
    }
}

private final class DependencyInjectingVisitor: Visitor {
    var dependencies: [Dependency]

    init(dependencies: [Dependency]) {
        self.dependencies = dependencies
    }

    func visitElement(name: String, attributes: [String : String], child: Node?) -> Node {
        if name == "head" {
            var tags = dependencies.map { dependency -> Node in
                switch dependency {
                case let .script(src: src, async: async):
                    return script(async: async, src: src)
                case let .stylesheet(href: href):
                    return link(href: href, rel: "stylesheet")
                }
            }

            if let child = child {
                tags.insert(child, at: 0)
            }

            return .element(name: name, attributes: attributes, child: .fragment(tags))
        }

        return .element(name: name, attributes: attributes, child: child.map(visitNode))
    }
}
