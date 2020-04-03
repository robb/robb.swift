import Foundation

public struct Site {
    public let baseURL: URL

    public var outputDirectory: URL {
        baseURL / "Site"
    }

    public init(baseDirectory: URL) throws {
        baseURL = baseDirectory
    }

    public func generate() throws -> [Resource] {
        let posts = try Post.jekyllPosts(in: baseURL / "Posts")

        let highlight = posts
            .filter { $0.category == "working-on" }
            .max(by: \.date)!

        let allPages = [
            About(),
            Archive(posts: posts),
            AtomFeed(baseURL: URL(string: "https://robb.is")!, posts: posts.suffix(10)),
            FrontPage(highlight: highlight),
            TakingPictures(posts: posts.filter { $0.category == "taking-pictures" })
        ] + posts.categoryIndices + posts

        let filters: [Filter] = [
            InlineFilter(baseURL: baseURL / "Inline"),
            MarkdownFilter(),
            PrismFilter(),
            DependencyFilter()
        ]

        let pageResources = allPages.concurrentMap { $0.applyFilters(filters) }

        let fileResources = try Resource.staticFiles(in: baseURL / "Resources")

        return pageResources + fileResources
    }
}
