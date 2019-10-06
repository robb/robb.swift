import Foundation
import HTML

protocol Page {
    static var defaultLayout: Layout { get }

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
    var path: String {
        "/" + pathComponents.joined(separator: "/")
    }
}
