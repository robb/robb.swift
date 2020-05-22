import Foundation
import HTML

struct GalleryIndex: Page {
    let title: String = "Photos"

    let pathComponents: [String] = ["taking-pictures"]

    func content() -> Node {
        [
            h1 {
                "Photos"
            },
            ul {
                li {
                    a(href: "/taking-pictures/Europe") {
                        "Europe"
                    }
                    " – mostly pictures from Berlin."
                }
                li {
                    a(href: "/taking-pictures/Japan") {
                        "Japan"
                    }
                    " – photos I've taken in Japan."
                }
                li {
                    a(href: "/taking-pictures/USA") {
                        "USA"
                    }
                    " – photos from when I lived in San Francisco and other times I traveled to the Bay Area."
                }
            }
        ]
    }
}
