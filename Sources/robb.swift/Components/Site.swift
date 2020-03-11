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
}
