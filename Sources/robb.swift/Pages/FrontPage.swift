import Foundation
import HTML

struct FrontPage: Page {
    let title = "Robert Böhnke"

    let url = "/"

    func render() -> Node {
        defaultLayout(page: self) {
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

                            span(classes: "strikethrough") {
                                span(customData: ["summary": "at&nbsp;Apple"], classes: "token") {
                                    "in the Health team at Apple"
                                }
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

                        span(classes: "shake") {
                            "👋🏻"
                        }
                    }
                }

                p {
                    "You can check out some of my"
                    a(href: "/taking-pictures") { "photos" }
                    "or learn"
                    a(href: "/who-exactly") { "more about me" } %% "."
                }

                script(type: "text/javascript") {
                    InlineFilter.inline(file: "js/intro.js")
                }
            }
        }
    }
}
