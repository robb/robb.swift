import Foundation

extension Post {
    /// Generates a `Post` for each Jekyll-style markdown file in `directory`
    /// as well as a `CategoryIndex`.
    static func jekyllPosts(in directory: URL) throws -> [Post] {
        try FileManager.default
            .contentsOfDirectory(atPath: directory.path)
            .map { directory / $0 }
            .concurrentMap {
                try? Post(contentsOfJekyllPost: $0)
            }
            .compactMap { $0 }
            .sorted(by: \.date)
    }
}

extension Array where Element == Post {
    var categoryIndices: [Page] {
        self
            .filter {
                $0.category != nil
            }
            .grouped {
                $0.category!
            }
            .map(CategoryIndex.init)
    }
}

private extension Sequence {
    func grouped<Key: Hashable>(by index: (Element) throws -> Key) rethrows -> Dictionary<Key, [Element]> {
        try Dictionary(grouping: self, by: index)
    }
}

private let isoDateFormatter = ISO8601DateFormatter()

private extension Post {
    init(contentsOfJekyllPost url: URL) throws {
        let post = try String(contentsOf: url)

        let frontMatter: [String: String]
        let body: String

        // Parse the YAML front matter, this will not handle nesting or arrays
        // ¯\_(ツ)_/¯
        do {
            let scanner = Scanner(string: post)

            _ = scanner.scanString("---")

            let header = scanner.scanUpToString("---")

            _ = scanner.scanString("---")

            body = String(scanner.string[scanner.currentIndex...])

            if let header = header {
                let pairs = String(header)
                    .split(separator: "\n")
                    .map { lines in
                        lines
                            .split(separator: ":", maxSplits: 1)
                            .map {
                                $0.trimmingCharacters(in: .whitespaces)
                            }
                    }
                    .filter {
                        $0.count == 2
                    }
                    .map {
                        ($0[0], $0[1])
                    }

                frontMatter = Dictionary(pairs) { a, _ in a }
            } else {
                frontMatter = [:]
            }
        }

        let title = frontMatter["title"] ?? url.lastPathComponent
        let slug = frontMatter["slug"] ?? title.lowercased().replacingOccurrences(of: " ", with: "-")
        let category = frontMatter["category"]

        self.category = category
        self.body = body
        self.date = frontMatter["date"].flatMap(isoDateFormatter.date) ?? Date(filename: url.lastPathComponent)!
        self.description = frontMatter["description"]
        self.image = frontMatter["image"]
        self.link = frontMatter["link"]
        self.title = title
        self.pathComponents = frontMatter["permalink"]?.pathComponents
            ?? [ category, slug ].compactMap { $0?.trimmingTrailingSlash() }
    }
}

private extension String {
    func trimmingTrailingSlash() -> String {
        if last == "/" {
            return String(dropLast())
        } else {
            return self
        }
    }
}

private extension String {
    var pathComponents: [String] {
        split(separator: "/").map(String.init)
    }
}
