import Foundation
import HTML

struct TakingPictures: Page {
    var posts: [Post]

    let title: String = "Taking Pictures"

    let pathComponents = [ "taking-pictures" ]

    func content() -> Node {
        posts
            .sorted { a, b in
                a.date > b.date
            }
            .map { post in
                article {
                    h1 {
                        a(href: post.path) {
                            post.title
                        }
                    }

                    MarkdownFilter.markdown {
                        post.body
                    }
                }
            }
            .asNode()
    }
}

