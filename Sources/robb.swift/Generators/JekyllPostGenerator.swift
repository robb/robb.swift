import Foundation

/// Generates a `Post` for each Jekyll-style markdown file in `directory` as well as a `CategoryIndex`.
struct JekyllPostGenerator: Generator {
    var directory: URL

    init(directory: URL) {
        self.directory = directory
    }

    func generate() throws -> [Page] {
        let posts = try FileManager.default
            .contentsOfDirectory(atPath: directory.path)
            .map {
                directory.appendingPathComponent($0)
            }
            .concurrentMap {
                try? Post(contentsOfJekyllPost: $0)
            }
            .compactMap { $0 }
            .sorted { a, b in
                a.date < b.date
            }

        let indices = posts
            .filter {
                $0.category != nil && $0.category != "taking-pictures"
            }
            .grouped {
                $0.category!
            }
            .map(CategoryIndex.init)

        return posts + indices
    }
}

private extension Sequence {
    func grouped<Key: Hashable>(by index: (Element) throws -> Key) rethrows -> Dictionary<Key, [Element]> {
        try Dictionary(grouping: self, by: index)
    }
}

private extension Post {
    init(contentsOfJekyllPost url: URL) throws {
        let post = try String(contentsOf: url)

        let frontMatter: [String: String]
        let body: String

        // Parse the YAML front matter, this will not handle nesting or arrays
        // ¯\_(ツ)_/¯
        do {
            let scanner = Scanner(string: post)

            var header: NSString?

            scanner.scanString("---", into: nil)
            scanner.scanUpTo("---", into: &header)
            scanner.scanString("---", into: nil)

            body = String(scanner.string.dropFirst(scanner.scanLocation))

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

        let isoDateFormatter = ISO8601DateFormatter()

        self.category = category
        self.body = body
        self.date = frontMatter["date"].flatMap(isoDateFormatter.date) ?? Date(from: url.lastPathComponent)!
        self.description = frontMatter["description"]
        self.image = frontMatter["image"]
        self.link = frontMatter["link"]
        self.title = title
        self.pathComponents = frontMatter["permalink"]?.pathComponents
            ?? [ category, slug ].compactMap { $0?.trimmingTrailingSlash() }
    }
}

private extension Date {
    init?(from title: String) {
        var year = 0, month = 0, day = 0

        let scanner = Scanner(string: title)

        guard scanner.scanInt(&year)
            && scanner.scanString("-", into: nil)
            && scanner.scanInt(&month)
            && scanner.scanString("-", into: nil)
            && scanner.scanInt(&day) else {
                return nil
        }

        let components = DateComponents(year: year, month: month, day: day)

        if let date = Calendar(identifier: .gregorian).date(from: components) {
            self = date
        } else {
            return nil
        }
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
