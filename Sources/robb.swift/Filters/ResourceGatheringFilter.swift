import Foundation
import HTML

/// Collects all `Resource` references in a `Node` tree.
struct ResourceGatheringFilter: Filter {
    var baseURL: URL

    func apply(node: Node, resources: inout Set<Resource>) -> Node {
        let visitor = ResourceGatheringVisitor(baseURL: baseURL)

        defer {
            resources.formUnion(visitor.resources)
        }

        visitor.visitNode(node)

        return node
    }
}

private final class ResourceGatheringVisitor: Visitor {
    var baseURL: URL

    var resources: Set<Resource> = []

    let attributeByName = [
        "img": "src",
        "link": "href",
        "script": "src"
    ]

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func visitElement(name: String, attributes: [String : String], child: Node?) -> Void {
        defer {
            if let child = child {
                visitNode(child)
            }
        }

        guard let attribute = attributeByName[name] else {
            return
        }

        guard let value = attributes[attribute] else {
            return
        }

        guard let resource = Resource(src: value, baseURL: baseURL) else {
            return
        }

        resources.insert(resource)

        var copy = attributes
        copy[attribute] = resource.path
    }

    func visitFragment(children: [Node]) -> Void {
        children.concurrentForEach(visitNode)
    }
}

private extension Resource {
    init?(src attribute: String, baseURL: URL) {
        let url = URL(string: attribute)

        switch url?.scheme {
        case nil:
            let url = baseURL / attribute.trimmingLeadingSlash()

            self.init(path: attribute, url: url)
        case "file":
            let path = "/" + url!.relativePath(to: baseURL)

            self.init(path: path, url: url!)
        default:
            return nil
        }
    }
}

private extension String {
    func trimmingLeadingSlash() -> String {
        if first == "/" {
            return String(dropFirst())
        } else {
            return self
        }
    }
}
