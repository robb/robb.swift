import Foundation
import HTML

struct Layout {
    var template: (Page, () -> Node) -> Node

    init(template: @escaping (Page, () -> Node) -> Node) {
        self.template = template
    }

    func render(page: Page, @NodeBuilder content: () -> Node) -> Node {
        template(page, content)
    }
}

extension Layout {
    private static let navigation = nav(id: "navigation") {
        style {
            InlineFilter.inline(file: "css/navigation.css")
        }
        h1 {
            a(href: "/") { "robb.is" }
        }
        ul {
            li {
                a(href: "/taking-pictures") { "Photos" }
            }
            li {
                a(href: "/who-exactly") { "About Me" }
            }
            li {
                a(href: "/archive") { "Archive" }
            }
        }
    }

    static let basic = Layout { page, content in
        [
            Node.documentType("html"),
            html(lang: "en-US") {
                head {
                    meta(charset: "utf-8")
                    meta(content: "en-US", httpEquiv: "content-language")

                    meta(content: "Robert Böhnke", name: "author")
                    meta(content: "Robert Böhnke", name: "publisher")
                    meta(content: "Robert Böhnke", name: "copyright")

                    meta(content: "width=device-width, initial-scale=1.0", name: "viewport")

                    (page as? Post).map { post -> Node in
                        return .fragment([
                            meta(content: "summary", name: "twitter:card"),
                            meta(content: "@DLX", name: "twitter:site"),
                            meta(content: post.title, name: "twitter:title"),
                            post.image.map {
                                meta(content: "https://robb.is" + $0, name: "twitter:image")
                            },
                            post.description.map {
                                meta(content: $0, name: "twitter:description")
                            }
                        ].compactMap { $0 })
                    } ?? []

                    title {
                        page.title; "– robb.is"
                    }

                    style {
                        InlineFilter.inline(file: "css/base.css")
                    }
                }
                body {
                    content()
                }
            }
        ]
    }

    static let empty = Layout { _, content in content() }

    static let page = Layout { page, content in
        basic.render(page: page) {
            header(id: "header") {
                navigation
            }

            section(id: "content") {
                content()
            }
        }
    }
}
