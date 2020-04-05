import Foundation
import HTML

/// Collects all `Resource` references in a `Node` tree.
struct ResourceGatheringFilter: Filter {
    var baseURL: URL

    func apply(node: Node, resources: inout Set<Resource>) -> Node {
        let visitor = ResourceGatheringVisitor(baseURL: baseURL)

        visitor.visitNode(node)

        resources.formUnion(visitor.resources)

        return node
    }
}

private final class ResourceGatheringVisitor: Visitor {
    var baseURL: URL

    var resources: Set<Resource> = []

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func visitElement(name: String, attributes: [String : String], child: Node?) {
        switch name {
        case "img":
            if let src = attributes["src"], !src.isURL {
                let source = baseURL / src.trimmingLeadingSlash()

                let resource = Resource(path: src, url: source)

                resources.insert(resource)
            }
        case "link":
            if let href = attributes["href"], !href.isURL {
                let source = baseURL / href.trimmingLeadingSlash()

                let resource = Resource(path: href, url: source)

                resources.insert(resource)
            }
        case "script":
            if let src = attributes["src"], !src.isURL {
                let source = baseURL / src.trimmingLeadingSlash()

                let resource = Resource(path: src, url: source)

                resources.insert(resource)
            }
        default:
            break
        }

        if let child = child {
            visitNode(child)
        }
    }
}

private extension String {
    var isURL: Bool {
        URL(string: self)?.scheme != nil
    }

    func trimmingLeadingSlash() -> String {
        if first == "/" {
            return String(dropFirst())
        } else {
            return self
        }
    }
}
