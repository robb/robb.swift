import Foundation
import HTML

struct FrontPage: Page {
    let title = "Robert Böhnke"

    let url = "/"

    func render() -> Node {
        defaultLayout(page: self) {
            header(id: "header") {
                style(type: "text/css") {
                    ###"""
                @keyframes fadeIn {
                    from { opacity: 0; }
                    to { opacity: 1; }
                }

                @keyframes shake {
                      0% { transform: rotate(  0.0deg); }
                     20% { transform: rotate(  7.0deg); }
                     40% { transform: rotate(-10.0deg); }
                     60% { transform: rotate( 11.0deg); }
                     80% { transform: rotate( -9.0deg); }
                    100% { transform: rotate(  0.0deg); }
                }

                #intro {
                    margin: 7.5rem 0 1.25rem 0;
                }

                @media (max-height: 680px) {
                    #intro {
                        margin-top: 5rem;
                    }
                }

                #intro .summary {
                    border-bottom: 1px dashed;
                    cursor: pointer;
                }

                #intro p {
                    display: inline;
                    font-size: 1.8rem;
                    font-weight: 400;
                    hyphens: manual;
                    line-height: 3rem;
                }

                #intro p:after {
                    content: " ";
                }

                #intro a {
                    border-bottom: 1px solid rgba(0, 0, 0, 1);
                    cursor: pointer;
                    text-decoration: none;
                }

                #intro .shake {
                    animation-delay: 2.1s;
                    animation-duration: 1s;
                    animation-name: shake;
                    animation-timing-function: ease-out;
                    display: inline-block;
                    transform-origin: 70% 70%;
                }

                #intro .strikethrough {
                    text-decoration: line-through;
                    text-decoration-color: rgb(219, 61, 61);
                    -webkit-text-decoration-color: rgb(219, 61, 61);
                }
                """###
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
                    a(href: "/who-exactly") { "more about me" }  %% "."
                }

                script(type: "text/javascript") {
                    ###"""
                    "use strict";

                        var intro = document.querySelector("#intro");

                        intro
                            .querySelectorAll(".token")
                            .forEach(function(element) {
                                var node = document.createElement("span");

                                node.appendChild(document.createTextNode(element.getAttribute("data-summary")));
                                node.classList.add("summary");

                                var parent = element.parentElement;

                                node.onclick = function() {
                                    intro.classList.add("activated");

                                    node.replaceWith(element);

                                    element.style.animationDuration = "0.4s";
                                    element.style.animationName = "fadeIn";
                                };
                                element.replaceWith(node);
                            });
                    """###
                }
            }
        }
    }
}
