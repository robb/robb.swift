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

        return visitor.visitNode(node)
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

    func visitElement(name: String, attributes: [String : String], child: Node?) -> Node {
        guard let attribute = attributeByName[name] else {
            return .element(name, attributes, child.map(visitNode))
        }

        guard let value = attributes[attribute] else {
            return .element(name, attributes, child.map(visitNode))
        }

        guard let resource = Resource(src: value, baseURL: baseURL) else {
            return .element(name, attributes, child.map(visitNode))
        }

        resources.insert(resource)

        var copy = attributes
        copy[attribute] = resource.path

        return .element(name, copy, child.map(visitNode))
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
