import Foundation
import HTML

protocol Page {
    var title: String { get }

    var url: String { get }

    func render() -> Node
}
