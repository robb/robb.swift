import Foundation
import HTML

struct Archive: Page {
    var posts: [Post]

    let title = "Archive"

    let pathComponents = [ "archive" ]

    func content() -> Node {
        ul {
            posts
                .reversed()
                .map { post in
                    li {
                        a(href: post.path) {
                            format(post.date)
                            " – "
                            post.title
                        }
                    }
                }
        }
    }
}
