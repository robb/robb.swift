import Foundation
import HTML

private let calendar = Calendar(identifier: .gregorian)

struct Post {
    var category: String?

    var content: String

    var date: Day

    var description: String?

    var link: String?

    var slug: String

    var title: String

    var isProject: Bool = false

    var url: String
}

extension Post: Page {
    func render() -> Node {
        pageLayout {
            article {
                header {
                    h1 {
                        a(href: link ?? url) {
                            title
                        }

                        if link != nil {
                            "(" %% a(href: url) { "Permalink" } %% ")"
                        }
                    }
                }

                MarkdownFilter.markdown {
                    content
                }

                if category != nil && category != "taking-pictures" {
                    small {
                        "Posted"
                        time {
                            format(date)
                        }
                        "in"; a(href: "/" + category!) { category! }
                    }
                }
            }
        }
    }
}
