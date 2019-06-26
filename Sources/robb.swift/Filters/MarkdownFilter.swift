import Down
import class Down.Text
import Foundation
import libcmark
import HTML

/// This filter converts all its immediate text node children from Markdown to HTML.
///
/// For example,
///
/// ```swift
/// MarkdownFilter.markdown {
///     "# Hello"
///
///     "You are"; username
/// }
/// ```
///
/// will render as
///
/// ```html
/// <section>
///     <h1>Hello</h1>
///
///     You are Johnny Appleseed
/// </section>
/// ```
struct MarkdownFilter: Filter {
    static func markdown(@NodeBuilder content: () -> NodeBuilderComponent) -> HTML.Node {
        Tag(name: "custom-markdown", children: content().asNodeArray)
    }

    static func render(_ string: String) -> HTML.Node? {
        let ast = try! Down(markdownString: string).toAST()

        let document = ast.wrap() as? Document

        return document!.accept(MarkdownToHTMLVisitor())
    }

    func apply(node input: HTML.Node) -> [HTML.Node] {
        guard let node = input as? Tag, node.name == "custom-markdown" else {
            return  [ input ]
        }

        return node.children.compactMap { child in
            guard let text = child as? HTML.Text else { return child }

            return MarkdownFilter.render(text.value)
        }
    }
}

private struct MarkdownToHTMLVisitor: Visitor {
    func visit(document node: Document) -> HTML.Node? {
        article(classes: "markdown") {
            visitChildren(of: node)
        }
    }

    func visit(blockQuote node: BlockQuote) -> HTML.Node? {
        blockquote {
            visitChildren(of: node)
        }
    }

    func visit(list node: List) -> HTML.Node? {
        switch node.listType {
        case .bullet:
            return ul {
                visitChildren(of: node)
            }
        case .ordered:
            return ol {
                visitChildren(of: node)
            }
        }
    }

    func visit(item node: Item) -> HTML.Node? {
        li {
            visitChildren(of: node)
        }
    }

    func visit(codeBlock node: CodeBlock) -> HTML.Node? {
        guard let content = node.literal else { return nil }

        return figure(classes: "highlight") {
            pre {
                %code {
                    content
                }%
            }
        }
    }

    func visit(htmlBlock node: HtmlBlock) -> HTML.Node? {
        HTML.Text(value: node.literal ?? "")
    }

    func visit(customBlock node: CustomBlock) -> HTML.Node? {
        fatalError("What is a CustomBlock?")
    }

    func visit(paragraph node: Paragraph) -> HTML.Node? {
        p {
            visitChildren(of: node)
        }
    }

    func visit(heading node: Heading) -> HTML.Node? {
        switch node.headingLevel {
        case 2:
            return h2 { visitChildren(of: node) }
        case 3:
            return h3 { visitChildren(of: node) }
        case 4:
            return h4 { visitChildren(of: node) }
        case 5:
            return h5 { visitChildren(of: node) }
        case 6:
            return h6 { visitChildren(of: node) }
        default:
            return h1 { visitChildren(of: node) }
        }
    }

    func visit(thematicBreak node: ThematicBreak) -> HTML.Node? {
        hr()
    }

    func visit(text node: Text) -> HTML.Node? {
        guard let content = node.literal else { return nil }

        return HTML.Text(value: content)
    }

    func visit(softBreak node: SoftBreak) -> HTML.Node? {
        HTML.Text(value: "")
    }

    func visit(lineBreak node: LineBreak) -> HTML.Node? {
        br()
    }

    func visit(code node: Code) -> HTML.Node? {
        guard let content = node.literal else { return nil }

        var snippet = code {
            content
        }

        snippet.trimMode.insert(.leadingSibling)
        snippet.trimMode.insert(.trailingSibling)

        return snippet
    }

    func visit(htmlInline node: HtmlInline) -> HTML.Node? {
        HTML.Text(value: node.literal ?? "")
    }

    func visit(customInline node: CustomInline) -> HTML.Node? {
        fatalError("What is a CustomInline?")
    }

    func visit(emphasis node: Emphasis) -> HTML.Node? {
        var emphasis = em {
            visitChildren(of: node)
        }

        emphasis.trimMode.insert(.leadingSibling)
        emphasis.trimMode.insert(.trailingSibling)

        return emphasis
    }

    func visit(strong node: Strong) -> HTML.Node? {
        var bold = strong {
            visitChildren(of: node)
        }

        bold.trimMode.insert(.leadingSibling)
        bold.trimMode.insert(.trailingSibling)

        return bold
    }

    func visit(link node: Link) -> HTML.Node? {
        var link = a(href: node.url, title: node.title) {
            visitChildren(of: node)
        }

        link.trimMode.insert(.leadingSibling)
        link.trimMode.insert(.trailingSibling)

        return link
    }

    func visit(image node: Image) -> HTML.Node? {
        img(src: node.url, title: node.title)
    }

    func visitChildren(of node: BaseNode) -> [HTML.Node] {
        visitChildren(of: node).compactMap { $0 }
    }
}
