import Foundation
import HTML

/// A `Filter` allows modifying `Node`s before rendering the `Site`.
protocol Filter {
    func apply(node: Node) -> [Node]
}

extension Filter {
    func applyRecusively(root: Node) -> [Node] {
        apply(node: root)
            .map { node in
                guard var tag = node as? Tag else { return node }

                tag.children = tag.children.flatMap(applyRecusively)

                return tag
            }
    }
}
