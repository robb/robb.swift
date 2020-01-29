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
                    span(class: "token", customAttributes: ["data-summary": "Robb"]) {
                        span(class: "token", customAttributes: ["data-summary": "Robert"]) {
                            "Robert Böhnke"
                        } %% ", but you can call me Robb"
                    } %% "."
                }

                p {
                    "Iʼm&nbsp;a"
                    span(class: "token", customAttributes: ["data-summary": "soft&shy;ware de&shy;velop&shy;er"]) {
                        "soft&shy;ware de&shy;velop&shy;er"

                        span(class: "token", customAttributes: ["data-summary": "at&nbsp;Google"]) {
                            "in the Kernel team at Google"
                        }
                    } %% "."
                }

                p {
                    "I&nbsp;"
                    %%
                        span(class: "token", customAttributes: ["data-summary": "live in Berlin"]) {
                        "live in Berlin where I was born and raised"
                    }
                    %%
                    ".&nbsp;"
                    %%
                    span(class: "shake") {
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
