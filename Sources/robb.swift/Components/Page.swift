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
    func applyLayout(_ layout: Layout = Self.defaultLayout) -> Node {
        layout.render(page: self) {
            content()
        }
    }
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

    func applyFilters(_ filters: [Filter]) -> Resource {
        let filtered = filters.reduce(applyLayout()) { node, filter in
            filter.apply(node: node)
        }

        let data = String(describing: filtered).data(using: .utf8) ?? Data()

        return Resource(contentType: contentType, path: path, data: data)
    }
}
