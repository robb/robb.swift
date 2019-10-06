import Down
import class Down.Text
import protocol Down.Visitor
import Foundation
import libcmark
import HTML

/// This filter converts all its text node children from Markdown to HTML.
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
    static func markdown(@NodeBuilder content: () -> NodeConvertible) -> HTML.Node {
        .element(name: "custom-markdown", child: content().asNode())
    }

    static func render(_ string: String) -> HTML.Node? {
        let ast = try! Down(markdownString: string).toAST()

        let document = ast.wrap() as? Document

        return document!.accept(MarkdownToHTMLVisitor())
    }

    func apply(node: HTML.Node) -> HTML.Node {
        let visitor = MarkdownFilterVisitor()

        return visitor.visitNode(node)
    }
}

private final class MarkdownFilterVisitor: HTML.Visitor {
    typealias Result = HTML.Node

    var isInsideMarkdownTag = false

    func visitElement(name: String, attributes: [String : String], child: HTML.Node) -> HTML.Node {
        guard name == "custom-markdown" else {
            return .element(name: name, attributes: attributes, child: visitNode(child))
        }

        isInsideMarkdownTag = true
        defer {
            isInsideMarkdownTag = false
        }

        return visitNode(child)
    }

    func visitText(text: String) -> HTML.Node {
        guard isInsideMarkdownTag else { return .text(text) }

        return MarkdownFilter.render(text) ?? ""
    }
}

private final class MarkdownToHTMLVisitor: Visitor {
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
        .text(node.literal ?? "")
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

        return .text(content)
    }

    func visit(softBreak node: SoftBreak) -> HTML.Node? {
        .text("")
    }

    func visit(lineBreak node: LineBreak) -> HTML.Node? {
        br()
    }

    func visit(code node: Code) -> HTML.Node? {
        guard let content = node.literal else { return nil }

        return %code { content }%
    }

    func visit(htmlInline node: HtmlInline) -> HTML.Node? {
        .text(node.literal ?? "")
    }

    func visit(customInline node: CustomInline) -> HTML.Node? {
        fatalError("What is a CustomInline?")
    }

    func visit(emphasis node: Emphasis) -> HTML.Node? {
        %em {
            visitChildren(of: node)
        }%
    }

    func visit(strong node: Strong) -> HTML.Node? {
        %strong {
            visitChildren(of: node)
        }%
    }

    func visit(link node: Link) -> HTML.Node? {
        %a(href: node.url, title: node.title) {
            visitChildren(of: node)
        }%
    }

    func visit(image node: Image) -> HTML.Node? {
        img(src: node.url, title: node.title)
    }

    func visitChildren(of node: BaseNode) -> [HTML.Node] {
        visitChildren(of: node).compactMap { $0 }
    }
}
