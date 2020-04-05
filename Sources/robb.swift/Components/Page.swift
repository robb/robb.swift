import Foundation
import HTML

protocol Page {
    static var defaultLayout: Layout { get }

    var contentType: String { get }

    var title: String { get }

    var pathComponents: [String] { get }

    func content() -> Node
}

extension Page {
    static var defaultLayout: Layout { .page }
}

extension Page {
    var contentType: String {
        "text/html"
    }

    var path: String {
        "/" + pathComponents.joined(separator: "/")
    }

    func render(layout: Layout = Self.defaultLayout, filters: [Filter]) -> Set<Resource> {
        let root = layout.render(page: self) {
            content()
        }

        var resources: Set<Resource> = []

        let filtered = filters.reduce(root) { node, filter in
            filter.apply(node: node, resources: &resources)
        }

        let data = String(describing: filtered).data(using: .utf8) ?? Data()

        resources.insert(Resource(contentType: contentType, path: path, data: data))

        return resources
    }
}
