import Foundation
import HTML

struct About: Page {
    let title = "Who Exactly?"

    let pathComponents = [ "who-exactly" ]

    func content() -> Node {
        MarkdownFilter.markdown {
            InlineFilter.inline(file: "md/about.md")
        }
    }
}
