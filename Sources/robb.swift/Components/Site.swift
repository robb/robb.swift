import Foundation

struct Site: ResourceGenerator {
    let baseURL: URL

    var outputDirectory: URL {
        baseURL.appendingPathComponent("Site")
    }

    init(baseDirectory: URL) throws {
        baseURL = baseDirectory
    }

    func generate() throws -> [Resource] {
        let pageGenerators = [
            JekyllPostGenerator(directory: baseURL.appendingPathComponent("Posts"))
        ]

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

        let filters: [Filter] = [
            InlineFilter(baseURL: baseURL.appendingPathComponent("Inline")),
            MarkdownFilter(),
            PrismFilter(),
            DependencyFilter()
        ]

        let pageResources = allPages.concurrentMap { $0.applyFilters(filters) }

        let resourceGenerators = [
            StaticFileGenerator(directory: baseURL.appendingPathComponent("Resources"))
        ]

        let fileResources = try resourceGenerators.flatMap { try $0.generate() }

        return pageResources + fileResources
    }
}
