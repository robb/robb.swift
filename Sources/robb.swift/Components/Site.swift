import Foundation

struct Site {
    let filters: [Filter]

    let pageGenerators: [PageGenerator]

    let outputDirectory: URL

    let resourcesDirectory: URL

    init(baseDirectory baseURL: URL) throws {
        filters = [
            InlineFilter(baseURL: baseURL.appendingPathComponent("Inline")),
            MarkdownFilter(),
            PrismFilter(),
            DependencyFilter()
        ]

        pageGenerators = [
            JekyllPostGenerator(directory: baseURL.appendingPathComponent("Posts"))
        ]

        resourcesDirectory = baseURL.appendingPathComponent("Resources")
        outputDirectory = baseURL.appendingPathComponent("Site")
    }

    private func build() throws -> [Resource] {
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
            AtomFeed(baseURL: URL(string: "https://robb.is")!, posts: posts.suffix(10)),
            FrontPage(highlight: highlight),
            TakingPictures(posts: posts.filter { $0.category == "taking-pictures" })
        ]

        let filters = self.filters

        let pageResources = allPages
            .concurrentMap { page -> Resource in
                let unfiltered = page.applyLayout()

                let filtered = filters
                    .reduce(unfiltered) { node, filter in
                        filter.apply(node: node)
                    }

                let data = String(describing: filtered).data(using: .utf8) ?? Data()

                return Resource(contentType: page.contentType, path: page.path, data: data)
            }

        let resourcesDirectory = self.resourcesDirectory

        let fileResources = try FileManager.default
            .findVisibleFiles(in: resourcesDirectory)
            .concurrentMap { url -> Resource in
                let path = url.relativePath(to: resourcesDirectory)

                return Resource(path: path, url: url)
            }

        return pageResources + fileResources
    }

    func sync(configuration: S3Uploader.Configuration) throws {
        let resources = try build()

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
        let resources = try build()

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
        let keySet = [ URLResourceKey.isRegularFileKey, .isHiddenKey ] as Set

        return enumerator(at: directory, includingPropertiesForKeys: keys)?
            .map {
                $0 as! URL
            }
            .filter { url in
                let resourceValues = try? url.resourceValues(forKeys: keySet)

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
