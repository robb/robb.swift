import Foundation
import HTML

struct FrontPage: Page {
    static let defaultLayout: Layout = .basic

    let title = "Robert Böhnke"

    let pathComponents = [] as [String]

    var highlight: Page

    func content() -> Node {
        header(id: "header") {
            style(type: "text/css") {
                InlineFilter.inline(file: "css/intro.css")
            }

            section(id: "intro") {
                p {
                    em { "Hi" } %% ", my name is"
                    span(customData: ["summary": "Robb"], classes: "token") {
                        span(customData: ["summary": "Robert"], classes: "token") {
                            "Robert Böhnke"
                        } %% ", but you can call me Robb"
                    } %% "."
                }

                p {
                    "Iʼm&nbsp;a"
                    span(customData: ["summary": "soft&shy;ware de&shy;velop&shy;er"], classes: "token") {
                        "soft&shy;ware de&shy;velop&shy;er"

                        span(customData: ["summary": "at&nbsp;Google"], classes: "token") {
                            "in the Kernel team at Google"
                        }
                    } %% "."
                }

                p {
                    "I&nbsp;"
                    %%
                    span(customData: ["summary": "live in Berlin"], classes: "token") {
                        "live in Berlin where I was born and raised"
                    }
                    %%
                    ".&nbsp;"
                    %%
                    span(classes: "shake") {
                       %"👋🏻"%
                    }
                }
            }

            p {
                "You can check out some of my"
                a(href: "/taking-pictures") { "photos" }
                %% ", learn"
                a(href: "/who-exactly") { "more about me" }
                "or read about my latest project:"
                a(href: highlight.path) { highlight.title } %% "."
            }

            script(type: "text/javascript") {
                InlineFilter.inline(file: "js/intro.js")
            }
        }
    }
}
