import Foundation

extension URL {
    func relativePath(to base: URL) -> String {
        let pathComponents = self.pathComponents
        let baseComponents = base.pathComponents

        guard pathComponents.starts(with: baseComponents) else {
            fatalError("\(self) is not contained inside \(base).")
        }

        return pathComponents
            .dropFirst(baseComponents.count)
            .joined(separator: "/")
    }

    static func / (lhs: URL, rhs: String) -> URL {
        lhs.appendingPathComponent(rhs)
    }
}
