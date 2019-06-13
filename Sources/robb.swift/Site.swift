import Foundation
import HTML
import Path

struct Site {
    var allPages: [Page] {
        return pages + posts
    }

    var filters: [Filter]

    var pages: [Page]

    var posts: [Post] = []

    var outputDirectory: URL

    var resources: [Resource] = []

    init(baseDirectory baseURL: URL) throws {
        let postsDirectory = baseURL.appendingPathComponent("Posts")
        let resourcesDirectory = baseURL.appendingPathComponent("Resources")
        let outputDirectory = baseURL.appendingPathComponent("Site")

        self.filters = [
            InlineFilter(baseURL: baseURL.appendingPathComponent("Inline"))
        ]

        self.outputDirectory = outputDirectory

        self.posts = try FileManager.default
            .contentsOfDirectory(atPath: postsDirectory.path)
            .map {
                postsDirectory.appendingPathComponent($0)
            }
            .map {
                try Post(contentsOfJekyllPost: $0)
            }
            .sorted { a, b in
                a.date < b.date
            }

        self.pages = [
            FrontPage(),
            Archive(posts: posts),
            About()
        ]

        let postsToIndex = posts.filter {
            $0.category != nil && $0.category != "taking-pictures"
        }

        let categoryIndices = Dictionary(grouping: postsToIndex) { $0.category! }

        self.pages.append(contentsOf: categoryIndices.map(CategoryIndex.init))

        self.pages.append(TakingPictures(posts: posts.filter { $0.category == "taking-pictures" }))

        let resourcePath = Path(url: resourcesDirectory)!
        let outputPath = Path(url: outputDirectory)!

        self.resources = try resourcePath
            .lsR(includeHiddenFiles: false)
            .map {
                $0.path
            }
            .map { origin -> Resource in
                let destination = outputPath / origin.relative(to: resourcePath)

                return Resource(origin: origin.url, destination: destination.url)
            }
    }

    func build() throws {
        let allPages = self.allPages

        DispatchQueue.concurrentPerform(iterations: allPages.count) { i in
            let page = allPages[i]

            try! write(page: page)
        }

        let resources = self.resources

        DispatchQueue.concurrentPerform(iterations: resources.count) { i in
            let resource = resources[i]

            let origin = Path(url: resource.origin)!
            let destination = Path(url: resource.destination)!

            try! destination.parent.mkdir(.p)
            try! origin.copy(to: destination, overwrite: true)
        }
    }

    private func write(page: Page) throws {
        let folder = Path(url: outputDirectory)! / page.url

        try folder.mkdir(.p)

        let file = folder / "index.html"

        try file.touch()

        let handle = try FileHandle(forWritingAt: file)

        var stream = FileHandlerOutputStream(handle)

        let content = page.render() as Node?

        let filtered = filters.reduce(content) { node, filter in
            guard let node = node else { return nil }

            return filter.applyRecusively(node: node)
        }

        guard let result = filtered else { return }

        result.write(to: &stream)

        handle.truncateFile(atOffset: handle.offsetInFile)
    }
}

private extension Path {
    func lsR(includeHiddenFiles: Bool = true) throws -> [Entry] {
        try ls(includeHiddenFiles: includeHiddenFiles)
            .flatMap { entry -> [Entry] in
                switch entry.kind {
                case .directory:
                    return try entry.path.lsR(includeHiddenFiles: includeHiddenFiles)
                case .file:
                    return [ entry ]
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
