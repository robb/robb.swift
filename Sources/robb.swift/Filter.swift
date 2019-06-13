import Foundation
import HTML

/// A `Filter` allows modifying `Node`s before rendering the `Site`.
protocol Filter {
    func apply(node: Node) -> Node?
}

extension Filter {
    func applyRecusively(node input: Node) -> Node? {
        let node = apply(node: input)

        if var tag = node as? Tag {
            tag.children = tag.children.compactMap(applyRecusively)

            return tag
        } else {
            return node
        }
    }
}
