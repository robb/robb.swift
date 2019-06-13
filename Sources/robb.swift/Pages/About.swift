import Foundation
import HTML

struct About: Page {
    let title = "Who Exactly?"

    let url = "/who-exactly"

    func render() -> Node {
        pageLayout(page: self) {
            MarkdownFilter.markdown {
                InlineFilter.inline(file: "md/about.md")
            }
        }
    }
}
