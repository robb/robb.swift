import Foundation

struct StaticFileGenerator: ResourceGenerator {
    var directory: URL
    
    init(directory: URL) {
        self.directory = directory
    }
    
    func generate() throws -> [Resource] {
        let directory = self.directory
        
        return try FileManager.default
            .findVisibleFiles(in: directory)
            .concurrentMap { url -> Resource in
                let path = url.relativePath(to: directory)
                
                return Resource(path: path, url: url)
        }
    }
}
