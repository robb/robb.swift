import Foundation
import HTML

struct About: Page {
    let title = "Who Exactly?"

    let url = "/who-exactly"

    func render() -> Node {
        pageLayout {
            MarkdownFilter.markdown {
                InlineFilter.inline(file: "md/about.md")
            }
        }
    }
}
