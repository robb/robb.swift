import Foundation
import HTML

struct AtomFeed: Page {
    static let defaultLayout: Layout = .empty

    let baseURL: URL

    let contentType = "application/xml"

    let dateFormatter = ISO8601DateFormatter()

    let markdownFilter = MarkdownFilter()

    let pathComponents = [ "atom.xml" ]

    let posts: [Post]

    let title = "robb.is"

    func content() -> Node {
        feed(xmlns: "http://www.w3.org/2005/Atom") {
            author {
                name {
                    "Robert Böhnke"
                }
            }
            title {
                self.title
            }
            id {
                "http://robb.is/"
            }
            updated {
                posts.last!.date
            }
            link(href: (baseURL / path).absoluteString, rel: "self")

            posts
                .reversed()
                .map { post in
                    entry {
                        title {
                            post.title
                        }
                        id {
                            (baseURL / post.path).absoluteString
                        }
                        link(href: post.link ?? (baseURL / post.path).absoluteString, rel: "alternate")
                        updated {
                            post.date
                        }

                        if post.description != nil {
                            summary {
                                post.description!
                            }
                        }

                        content(type: "html") {
                            XMLEncodingFilter.encode {
                                MarkdownFilter.markdown {
                                    post.content()
                                }
                            }
                        }
                    }
                }
        }
    }
}

extension AtomFeed {
    private func feed(xmlns: String, @NodeBuilder children: () -> NodeConvertible) -> Node {
        .element("feed", [ "xmlns": xmlns ], children().asNode())
    }

    private func author(@NodeBuilder children: () -> NodeConvertible) -> Node {
        .element("author", [:], children().asNode())
    }

    private func name(children: () -> String) -> Node {
        .element("name", [:], children().asNode())
    }

    private func title(type: String = "text", children: () -> String) -> Node {
        .element("title", [ "type": type ], %children().asNode()%)
    }

    private func id(children: () -> String) -> Node {
        .element("id", [:], %children().asNode()%)
    }

    private func updated(date: () -> Date) -> Node {
        .element("updated", [:], %.text(dateFormatter.string(from: date()))%)
    }

    private func entry(@NodeBuilder children: () -> NodeConvertible) -> Node {
        .element("entry", [:], children().asNode())
    }

    private func link(href: String, rel: String) -> Node {
        .element("link", [ "href": href, "rel": rel ], [])
    }

    private func summary(type: String = "text", children: () -> String) -> Node {
        .element("summary", [ "type": type ], children().asNode())
    }

    private func content(type: String = "text", @NodeBuilder children: () -> NodeConvertible) -> Node {
        .element("content", [ "type": type ], children().asNode())
    }
}
