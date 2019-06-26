import Foundation
import HTML
import Path

struct Site {
    var filters: [Filter]

    var generators: [Generator]

    var outputDirectory: URL

    var resourcesDirectory: URL

    init(baseDirectory baseURL: URL) throws {
        filters = [
            InlineFilter(baseURL: baseURL.appendingPathComponent("Inline")),
            MarkdownFilter()
        ]

        generators = [
            try JekyllPostGenerator(directory: baseURL.appendingPathComponent("Posts"))
        ]

        resourcesDirectory = baseURL.appendingPathComponent("Resources")
        outputDirectory = baseURL.appendingPathComponent("Site")
    }

    func build() throws {
        let pages = try generators.flatMap { try $0.generate() }

        let posts = pages.compactMap { $0 as? Post }

        let allPages = pages + [
            About(),
            Archive(posts: posts),
            FrontPage(),
            TakingPictures(posts: posts.filter { $0.category == "taking-pictures" })
        ]

        DispatchQueue.concurrentPerform(iterations: allPages.count) { i in
            let page = allPages[i]

            try! write(page: page)
        }

        let resourcePath = Path(url: resourcesDirectory)!
        let outputPath = Path(url: outputDirectory)!

        let resources = try resourcePath
            .lsR(includeHiddenFiles: false)
            .map {
                $0.path
            }
            .map { origin -> Resource in
                let destination = outputPath / origin.relative(to: resourcePath)

                return Resource(origin: origin.url, destination: destination.url)
            }

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

        let content = page.render()

        let filtered = filters
            .reduce([content]) { nodes, filter in
                nodes.flatMap(filter.applyRecusively)
            }

        for result in filtered {
            result.write(to: &stream)
        }

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
