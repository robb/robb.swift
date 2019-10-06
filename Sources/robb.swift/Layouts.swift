import Foundation
import HTML

private let navigation = nav(id: "navigation") {
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

extension Page {
    func defaultLayout(@NodeBuilder content: () -> NodeBuilderComponent) -> Node {
        html(lang: "en-US") {
            head {
                meta(charset: "utf-8")
                meta(content: "en-US", httpEquiv: "content-language")

                meta(content: "Robert Böhnke", name: "author")
                meta(content: "Robert Böhnke", name: "publisher")
                meta(content: "Robert Böhnke", name: "copyright")

                meta(content: "width=device-width, initial-scale=1.0", name: "viewport")

                HTML.title {
                    title; "– robb.is"
                }

                style {
                    InlineFilter.inline(file: "css/base.css")
                    InlineFilter.inline(file: "css/gallery.css")
                }
            }
            body {
                content()
            }
        }
    }

    func pageLayout(@NodeBuilder content: () -> NodeBuilderComponent) -> Node {
        defaultLayout {
            header(id: "header") {
                navigation
            }

            section(id: "content") {
                content()
            }
        }
    }
}
