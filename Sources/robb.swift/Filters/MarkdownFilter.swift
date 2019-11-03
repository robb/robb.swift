import Foundation
import HTML
import cmark

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
    static func markdown(@NodeBuilder content: () -> NodeConvertible) -> Node {
        .element(name: "custom-markdown", child: content().asNode())
    }

    static func render(_ string: String) -> Node? {
        let parser = MarkdownParser(document: string)

        return parser.parse()
    }

    func apply(node: Node) -> Node {
        let visitor = MarkdownFilterVisitor()

        return visitor.visitNode(node)
    }
}

private final class MarkdownFilterVisitor: Visitor {
    typealias Result = Node

    var isInsideMarkdownTag = false

    func visitElement(name: String, attributes: [String : String], child: Node) -> Node {
        guard name == "custom-markdown" else {
            return .element(name: name, attributes: attributes, child: visitNode(child))
        }

        isInsideMarkdownTag = true
        defer {
            isInsideMarkdownTag = false
        }

        return visitNode(child)
    }

    func visitText(text: String) -> Node {
        guard isInsideMarkdownTag else { return .text(text) }

        return MarkdownFilter.render(text) ?? ""
    }
}

private final class MarkdownParser {
    private var root: OpaquePointer?

    init(document: String) {
        root = document.withCString { body in
            cmark_parse_document(body, strlen(body), 0)
        }
    }

    deinit {
        cmark_node_free(root)
    }

    func parse() -> Node? {
        root.flatMap(visitNode)
    }

    func visitNode(_ node: OpaquePointer) -> Node? {
        switch cmark_node_get_type(node) {
        case CMARK_NODE_DOCUMENT:       return visit(document: node)
        case CMARK_NODE_BLOCK_QUOTE:    return visit(blockQuote: node)
        case CMARK_NODE_LIST:           return visit(list: node)
        case CMARK_NODE_ITEM:           return visit(item: node)
        case CMARK_NODE_CODE_BLOCK:     return visit(codeBlock: node)
        case CMARK_NODE_HTML_BLOCK:     return visit(htmlBlock: node)
        case CMARK_NODE_CUSTOM_BLOCK:   return visit(customBlock: node)
        case CMARK_NODE_PARAGRAPH:      return visit(paragraph: node)
        case CMARK_NODE_HEADING:        return visit(heading: node)
        case CMARK_NODE_THEMATIC_BREAK: return visit(thematicBreak: node)

        case CMARK_NODE_TEXT:           return visit(text: node)
        case CMARK_NODE_SOFTBREAK:      return visit(softBreak: node)
        case CMARK_NODE_LINEBREAK:      return visit(lineBreak: node)
        case CMARK_NODE_CODE:           return visit(code: node)
        case CMARK_NODE_HTML_INLINE:    return visit(htmlInline: node)
        case CMARK_NODE_CUSTOM_INLINE:  return visit(customInline: node)
        case CMARK_NODE_EMPH:           return visit(emphasis: node)
        case CMARK_NODE_STRONG:         return visit(strong: node)
        case CMARK_NODE_LINK:           return visit(link: node)
        case CMARK_NODE_IMAGE:          return visit(image: node)
        default:
            return nil
        }
    }

    func visitChildren(of node: OpaquePointer?) -> [Node] {
        var current = cmark_node_first_child(node)

        let iterator = AnyIterator<OpaquePointer> {
            defer {
                current = cmark_node_next(current)
            }

            return current
        }

        return iterator.compactMap(visitNode)
    }

    func visit(document node: OpaquePointer) -> Node? {
        article(classes: "markdown") {
            visitChildren(of: node)
        }
    }

    func visit(blockQuote node: OpaquePointer) -> Node? {
        blockquote {
            visitChildren(of: node)
        }
    }

    func visit(list node: OpaquePointer) -> Node? {
        switch cmark_node_get_list_type(node) {
        case CMARK_BULLET_LIST:
            return ul {
                visitChildren(of: node)
            }
        case CMARK_ORDERED_LIST:
            return ol {
                visitChildren(of: node)
            }
       default:
            return nil
        }
    }

    func visit(item node: OpaquePointer) -> Node? {
        li {
            visitChildren(of: node)
        }
    }

    func visit(codeBlock node: OpaquePointer) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        return figure(classes: "highlight") {
            pre {
                %code {
                    content
                }%
            }
        }
    }

    func visit(htmlBlock node: OpaquePointer) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        return .text(content)
    }

    func visit(customBlock node: OpaquePointer) -> Node? {
        fatalError("What is a CustomBlock?")
    }

    func visit(paragraph node: OpaquePointer) -> Node? {
        p {
            visitChildren(of: node)
        }
    }

    func visit(heading node: OpaquePointer) -> Node? {
        switch cmark_node_get_heading_level(node) {
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

    func visit(thematicBreak node: OpaquePointer) -> Node? {
        hr()
    }

    func visit(text node: OpaquePointer) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        return .text(content)
    }

    func visit(softBreak node: OpaquePointer) -> Node? {
        .text("")
    }

    func visit(lineBreak node: OpaquePointer) -> Node? {
        br()
    }

    func visit(code node: OpaquePointer) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        return %code { content }%
    }

    func visit(htmlInline node: OpaquePointer) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        return .text(content)
    }

    func visit(customInline node: OpaquePointer) -> Node? {
        fatalError("What is a CustomInline?")
    }

    func visit(emphasis node: OpaquePointer) -> Node? {
        %em {
            visitChildren(of: node)
        }%
    }

    func visit(strong node: OpaquePointer) -> Node? {
        %strong {
            visitChildren(of: node)
        }%
    }

    func visit(link node: OpaquePointer) -> Node? {
        let url = String(cString: cmark_node_get_url(node))
        let title = String(cString: cmark_node_get_title(node))

        return %a(href: url, title: title) {
            visitChildren(of: node)
        }%
    }

    func visit(image node: OpaquePointer) -> Node? {
        let url = String(cString: cmark_node_get_url(node))
        let title = String(cString: cmark_node_get_title(node))

        return img(src: url, title: title)
    }
}
