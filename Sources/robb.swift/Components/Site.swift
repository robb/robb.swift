import Foundation

struct Site: ResourceGenerator {
    let baseURL: URL

    let filters: [Filter]

    let outputDirectory: URL

    let pageGenerators: [PageGenerator]

    let resourceGenerators: [ResourceGenerator]

    init(baseDirectory: URL) throws {
        baseURL = baseDirectory

        filters = [
            InlineFilter(baseURL: baseURL.appendingPathComponent("Inline")),
            MarkdownFilter(),
            PrismFilter(),
            DependencyFilter()
        ]

        pageGenerators = [
            JekyllPostGenerator(directory: baseURL.appendingPathComponent("Posts"))
        ]

        resourceGenerators = [
            StaticFileGenerator(directory: baseURL.appendingPathComponent("Resources"))
        ]

        outputDirectory = baseURL.appendingPathComponent("Site")
    }

    func generate() throws -> [Resource] {
        let pages = try pageGenerators.flatMap { try $0.generate() }

        let posts = pages.compactMap { $0 as? Post }

        let highlight = posts
            .filter { $0.category == "working-on" }
            .max { a, b in
                a.date < b.date
            }!

        let allPages = pages + [
            About(),
            Archive(posts: posts),
            AtomFeed(baseURL: baseURL, posts: posts.suffix(10)),
            FrontPage(highlight: highlight),
            TakingPictures(posts: posts.filter { $0.category == "taking-pictures" })
        ]

        let filters = self.filters

        let pageResources = allPages.concurrentMap { $0.applyFilters(filters) }

        let fileResources = try resourceGenerators.flatMap { try $0.generate() }

        return pageResources + fileResources
    }

    func sync(configuration: S3Uploader.Configuration) throws {
        let resources = try generate()

        let group = DispatchGroup()

        let uploader = S3Uploader(configuration: configuration)

        resources.concurrentForEach { resource in
            group.enter()
            uploader
                .uploadIfNeeded(resource: resource)
                .done { result in
                    group.leave()
                }
        }

        group.wait()
    }

    func write() throws {
        let resources = try generate()

        resources.concurrentForEach { resource in
            do {
                var file = outputDirectory.appendingPathComponent(resource.path)

                if resource.contentType == "text/html" {
                    file.appendPathComponent("index.html")
                }

                try FileManager.default.createDirectory(
                    at: file.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                try resource.write(to: file)
            } catch {
                print(resource.path, error)
            }
        }
    }
}

struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding

    init(_ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
}

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
}
