import Foundation

extension FileManager {
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
