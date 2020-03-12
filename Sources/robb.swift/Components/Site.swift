import Foundation

struct Site {
    let baseURL: URL

    var outputDirectory: URL {
        baseURL.appendingPathComponent("Site")
    }

    init(baseDirectory: URL) throws {
        baseURL = baseDirectory
    }

    func generate() throws -> [Resource] {
        let posts = try Post.jekyllPosts(in: baseURL.appendingPathComponent("Posts"))

        let highlight = posts
            .filter { $0.category == "working-on" }
            .max(by: \.date)!

        let allPages = [
            About(),
            Archive(posts: posts),
            AtomFeed(baseURL: baseURL, posts: posts.suffix(10)),
            FrontPage(highlight: highlight),
            TakingPictures(posts: posts.filter { $0.category == "taking-pictures" })
        ] + posts.categoryIndices + posts

        let filters: [Filter] = [
            InlineFilter(baseURL: baseURL.appendingPathComponent("Inline")),
            MarkdownFilter(),
            PrismFilter(),
            DependencyFilter()
        ]

        let pageResources = allPages.concurrentMap { $0.applyFilters(filters) }

        let fileResources = try Resource.staticFiles(in: baseURL.appendingPathComponent("Resources"))

        return pageResources + fileResources
    }
}
