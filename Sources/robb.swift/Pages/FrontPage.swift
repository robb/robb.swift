import Foundation
import HTML
import Swim

fileprivate func token(summary: String, @NodeBuilder children: () -> NodeConvertible = { Node.fragment([]) }) -> Node {
    span(class: "token", customAttributes: ["data-summary": summary]) {
        children()
    }
}

struct FrontPage: Page {
    static let defaultLayout: Layout = .basic

    let title = "Robert Böhnke"

    let pathComponents = [] as [String]

    var highlight: Page

    func content() -> Node {
        header(id: "header") {
            style {
                InlineFilter.inline(file: "css/intro.css")
            }

            section(id: "intro") {
                p {
                    em { "Hi" } %% ", my name is"
                    token(summary: "Robb") {
                        token(summary: "Robert") {
                            "Robert Böhnke"
                        } %% ", but you can call me Robb"
                    } %% "."
                }

                p {
                    "Iʼm working on "
                    a(href: "https://movingparts.io") {
                        "Moving Parts"
                    } %% "."
                }

                p {
                    .raw("I&nbsp;")
                    %%
                        token(summary: "live in Berlin") {
                        "live in Berlin where I was born and raised"
                    }
                    %%
                    .raw(".&nbsp;")
                    %%
                    span(class: "shake") {
                       "👋🏻"
                    }
                }
            }

            p {
                "You can check out some of the photos I’ve taken in"
                a(href: "/taking-pictures/Europe") {
                    "Berlin"
                } %% ","
                a(href: "/taking-pictures/Japan") {
                    "Japan"
                } %% " or the "
                a(href: "/taking-pictures/USA") {
                    "Bay Area"
                }
                "or read about my latest project:"
                a(href: highlight.path) { highlight.title } %% "."
                "You can also"
                a(href: "/who-exactly") {
                    "learn more about me"
                }
                "or follow me on"
                a(href: "https://github.com/robb") {
                    "GitHub"
                } %% ","
                a(href: "https://mastodon.social/@DLX", rel: "me") {
                    "Mastodon"
                } %% ","
                "and"
                a(href: "https://twitter.com/dlx") {
                    "Twitter"
                } %% "."
            }

            script(type: "text/javascript") {
                InlineFilter.inline(file: "js/intro.js")
            }
        }
    }
}
