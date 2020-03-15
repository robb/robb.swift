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
