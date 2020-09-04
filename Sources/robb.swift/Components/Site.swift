import Foundation

public struct Site {
    public let baseURL: URL

    public var outputDirectory: URL {
        baseURL / "Site"
    }

    public init(baseDirectory: URL) throws {
        baseURL = baseDirectory
    }

    public func generate() throws -> Set<Resource> {
        let posts = try Post.jekyllPosts(in: baseURL / "Posts")

        let highlight = posts
            .filter { $0.category == "working-on" }
            .max(by: \.date)!

        let allPages: [Page] = [
            posts,
            posts.categoryIndices,
            [
                About(),
                Archive(posts: posts),
                AtomFeed(baseURL: URL(string: "https://robb.is")!, posts: posts.suffix(10)),
                FrontPage(highlight: highlight),
                GalleryIndex(),
                Gallery(directory: baseURL / "Resources" / "photos" / "USA"),
                Gallery(directory: baseURL / "Resources" / "photos" / "Japan"),
                Gallery(directory: baseURL / "Resources" / "photos" / "Europe")
            ]
        ].flatMap { $0 }

        let filters: [Filter] = [
            InlineFilter(baseURL: baseURL / "Resources"),
            MarkdownFilter(),
            PrismFilter(),
            DependencyFilter(),
            ResourceGatheringFilter(baseURL: baseURL / "Resources"),
            XMLEncodingFilter(),
        ]

        let renderedPages = allPages.concurrentMap { $0.render(filters: filters) }

        return renderedPages.reduce([]) { $0.union($1) }
    }
}
