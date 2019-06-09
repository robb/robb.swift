import Foundation
import HTML

struct CategoryIndex: Page {
    var posts: [Post]

    var title: String

    var url: String

    init(category: String, posts: [Post]) {
        self.posts = posts

        self.title = category
            .split(separator: "-")
            .map {
                String($0)
            }
            .map {
                guard $0.count > 1 else { return String($0) }

                return $0.prefix(1) + $0.dropFirst().lowercased()
            }
            .joined(separator: " ")

        self.url = category
    }

    func render() -> Node {
        pageLayout(page: self) {
            ul {
                posts
                    .map { post in
                        li {
                            a(href: post.url) {
                                format(post.date)
                                " – "
                                post.title
                            }

                            if post.description != nil {
                                br()
                                post.description!
                            }
                        }
                }
            }
        }
    }
}
