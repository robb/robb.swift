import Foundation

extension Resource {
    static func staticFiles(in directory: URL) throws -> [Resource] {
        try FileManager.default
            .findVisibleFiles(in: directory)
            .concurrentMap { url -> Resource in
                let path = url.relativePath(to: directory)

                return Resource(path: path, url: url)
            }
    }
}

private extension FileManager {
    func findVisibleFiles(in directory: URL) throws -> [URL] {
        let keys = [ URLResourceKey.isRegularFileKey, .isHiddenKey ]

        return enumerator(at: directory, includingPropertiesForKeys: keys)?
            .map {
                $0 as! URL
            }
            .filter { url in
                let resourceValues = try? url.resourceValues(forKeys: Set(keys))

                return (resourceValues?.isRegularFile ?? false) &&
                    !(resourceValues?.isHidden ?? false)
            } ?? []
    }
}

private extension URL {
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
}
