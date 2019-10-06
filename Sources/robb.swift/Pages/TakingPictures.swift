import Foundation
import HTML

struct TakingPictures: Page {
    var posts: [Post]

    let title: String = "Taking Pictures"

    let url: String = "taking-pictures"

    func render() -> Node {
        pageLayout {
            posts
                .sorted { a, b in
                    a.date > b.date
                }
                .map { post in
                    article {
                        h1 {
                            a(href: post.url) {
                                post.title
                            }
                        }

                        MarkdownFilter.markdown {
                            post.content
                        }
                    }
            }
        }
    }
}
