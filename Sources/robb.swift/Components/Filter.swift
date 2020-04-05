import Foundation
import HTML

/// A `Filter` allows modifying `Node`s before rendering the `Site`.
protocol Filter {
    func apply(node: Node, resources: inout Set<Resource>) -> Node
}
