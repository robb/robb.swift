import Foundation
import HTML

func defaultLayout(page: Page, @NodeBuilder content: () -> NodeBuilderComponent) -> Node {
    html(lang: "en-US") {
        head {
            meta(charset: "utf-8")
            meta(content: "en-US", httpEquiv: "content-language")

            meta(content: "Robert Böhnke", name: "author")
            meta(content: "Robert Böhnke", name: "publisher")
            meta(content: "Robert Böhnke", name: "copyright")

            meta(content: "width=device-width, initial-scale=1.0", name: "viewport")

            title {
                page.title; " – robb.is"
            }

            style {
                InlineFilter.inline(file: "css/base.css")
            }
        }
        body {
            content()
        }
    }
}

func pageLayout(page: Page, @NodeBuilder content: () -> NodeBuilderComponent) -> Node {
    defaultLayout(page: page) {
        header(id: "header") {
            navigation
        }

        section(id: "content") {
            content()
        }
    }
}

let navigation = nav(id: "navigation") {
    style {
        """
        #navigation {
            margin: 1.25rem 0;

            display: flex;
            flex-direction: row;
            flex-wrap: nowrap;
            justify-content: space-between;
        }

        #navigation h1, #navigation li {
            font-size: 1rem;
            display: inline-block;
            line-height: 2rem;
            margin: 0;
        }

        #navigation li {
            list-style-type: none;
            margin-left: 0.625rem;
        }

        #navigation a {
            text-decoration: none;
        }
        """
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
