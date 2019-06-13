import Foundation
import HTML

struct TakingPictures: Page {
    var posts: [Post]

    let title: String = "Taking Pictures"

    let url: String = "taking-pictures"

    func render() -> Node {
        pageLayout(page: self) {
            posts
                .map { post in
                    article {
                        h1 {
                            a(href: post.url) {
                                post.title
                            }
                        }
                        
                        post.content
                    }
            }

        }
    }
}
