import Foundation
import HTML

private let calendar = Calendar(identifier: .gregorian)

struct Post {
    var category: String?

    var content: [HTML.Node]

    var date: Day

    var description: String?

    var link: String?

    var slug: String

    var title: String

    var isProject: Bool = false

    var url: String
}

extension Post {
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
                            .split(separator: ":")
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
        self.content = markdown(body)
        self.date = Day(from: url.lastPathComponent)!
        self.description = frontMatter["description"]
        self.slug = slug
        self.title = frontMatter["title"] ?? url.lastPathComponent
        self.url = frontMatter["permalink"] ?? [ "", category, slug ].compactMap { $0 }.joined(separator: "/")
    }
}

private extension Day {
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

        self = Day(year: year, month: month, day: day)
    }
}

extension Post: Page {
    func render() -> Node {
        pageLayout(page: self) {
            article {
                header {
                    h1 {
                        a(href: link ?? url) {
                            title
                        }

                        if link != nil {
                            "("; a(href: url) { "Permalink" }; ")"
                        }
                    }
                }

                content

                if category != nil && category != "taking-pictures" {
                    small {
                        "Posted"
                        time {
                            format(date)
                        }
                        "in"; a(href: "") { category! }
                    }
                }
            }
        }
    }
}
