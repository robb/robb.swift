import Foundation
import HTML

struct Archive: Page {
    var posts: [Post]

    let title = "Archive"

    let url = "archive"

    func render() -> Node {
        pageLayout(page: self) {
            ul {
                posts
                    .reversed()
                    .map { post in
                        li {
                            a(href: post.url) {
                                format(post.date)
                                " – "
                                post.title
                            }
                        }
                    }
            }
        }
    }
}
