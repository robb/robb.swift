import Foundation
import HTML

private let calendar = Calendar(identifier: .gregorian)

struct Post {
    var body: String

    var category: String?

    var date: Date

    var description: String?

    var isProject: Bool = false

    var image: String?

    var link: String?

    var pathComponents: [String]

    var title: String
}

extension Post: Page {
    func content() -> Node {
        MarkdownFilter.markdown {
            body
        }
    }
}

extension Post {
    static let defaultLayout: Layout = Layout { page, content in
        let post = page as! Post

        return Layout.page.render(page: post) {
            article {
                header {
                    h1 {
                        a(href: post.link ?? post.path) {
                            post.title
                        }

                        if post.link != nil {
                            "(" %% a(href: post.path) { "Permalink" } %% ")"
                        }
                    }
                }

                content()

                if post.category != nil && post.category != "taking-pictures" {
                    small {
                        "Posted"
                        time {
                            format(post.date)
                        }
                        "in"; a(href: "/" + post.category!) { post.category! }
                    }
                }
            }
        }
    }
}
