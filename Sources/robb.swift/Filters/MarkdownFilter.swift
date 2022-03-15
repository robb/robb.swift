import Foundation
import HTML
import cmark
import libxml2

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
/// <h1>Hello</h1>
///
/// You are Johnny Appleseed
/// ```
struct MarkdownFilter: Filter {
    static func markdown(@NodeBuilder content: () -> NodeConvertible) -> Node {
        .element("custom-markdown", [:], content().asNode())
    }

    static func render(_ string: String) -> Node? {
        let parser = MarkdownParser(document: string)

        return parser.parse()
    }

    func apply(node: Node, resources: inout Set<Resource>) -> Node {
        let visitor = MarkdownFilterVisitor()

        return visitor.visitNode(node)
    }
}

private final class MarkdownFilterVisitor: Visitor {
    typealias Result = Node

    var isInsideMarkdownTag = false

    func visitElement(name: String, attributes: [String : String], child: Node?) -> Node {
        guard name == "custom-markdown" else {
            return .element(name, attributes, child.map(visitNode))
        }

        isInsideMarkdownTag = true
        defer {
            isInsideMarkdownTag = false
        }

        return child.map(visitNode) ?? []
    }

    func visitText(text: String) -> Node {
        guard isInsideMarkdownTag else { return .raw(text) }

        return MarkdownFilter.render(text) ?? ""
    }

    func visitRaw(raw: String) -> Node {
        guard isInsideMarkdownTag else { return .raw(raw) }

        return MarkdownFilter.render(raw) ?? ""
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
        let iterator = AnyIterator(first: cmark_node_first_child(node), next: cmark_node_next)

        return iterator.compactMap(visitNode)
    }

    func visit(document node: OpaquePointer) -> Node? {
        .fragment(visitChildren(of: node))
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

        let language = String(cString: cmark_node_get_fence_info(node))

        return figure(class: "highlight") {
            pre {
                %code(class: "language-\(language)") {
                    content.addingXMLEncoding()
                }%
            }
        }
    }

    func visit(htmlBlock node: OpaquePointer) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        let options = [
            HTML_PARSE_NOERROR,
            HTML_PARSE_NOWARNING,
            HTML_PARSE_RECOVER,
            HTML_PARSE_NONET,
            HTML_PARSE_NOIMPLIED,
        ].map(\.rawValue).reduce(0, |)

        let doc = content.withCString { cString in
            htmlReadMemory(cString, Int32(content.utf8.count), "", nil, Int32(options))
        }
        defer {
            xmlFreeDoc(doc)
        }

        return visit(xml: xmlDocGetRootElement(doc))
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

        return .raw(content)
    }

    func visit(softBreak node: OpaquePointer) -> Node? {
        .raw("")
    }

    func visit(lineBreak node: OpaquePointer) -> Node? {
        br()
    }

    func visit(code node: OpaquePointer) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        return %code { content.addingXMLEncoding() }%
    }

    func visit(htmlInline node: OpaquePointer) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        return .raw(content)
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

        return %a(href: url, title: title.nilIfEmpty) {
            visitChildren(of: node)
        }%
    }

    func visit(image node: OpaquePointer) -> Node? {
        let url = String(cString: cmark_node_get_url(node))
        let title = String(cString: cmark_node_get_title(node))

        return img(src: url, title: title.nilIfEmpty)
    }
}

private extension MarkdownParser {
    func visit(xml nodePointer: UnsafeMutablePointer<xmlNode>?) -> Node? {
        switch nodePointer?.pointee.type {
        case XML_ELEMENT_NODE:
            return visit(element: nodePointer)
        case XML_TEXT_NODE, XML_CDATA_SECTION_NODE:
            return visit(text: nodePointer)
        case XML_COMMENT_NODE:
            return visit(comment: nodePointer)
        default:
            return nil
        }
    }

    func visit(element nodePointer: UnsafeMutablePointer<xmlNode>?) -> Node? {
        guard let node = nodePointer?.pointee else { return nil }

        guard let name = node.name.map({ String(cString: $0) }) else { return nil }

        let childIterator = AnyIterator(first: node.children, next: \.pointee.next)

        let children = childIterator
            .compactMap(visit(xml:))
            .nilIfEmpty
            .map(Node.fragment)

        let propertyIterator = AnyIterator(first: node.properties, next: \.pointee.next)

        let properties = propertyIterator.map { attribute -> (String, String) in
            let key = String(cString: attribute.pointee.name)
            let value = String(cString: xmlGetProp(nodePointer, attribute.pointee.name))

            return (key, value)
        }

        let attributes = Dictionary(properties, uniquingKeysWith: { a, _ in a})

        return .element(name, attributes, children)
    }

    func visit(text nodePointer: UnsafeMutablePointer<xmlNode>?) -> Node? {
        let content = nodePointer?.pointee.content.map({ String(cString: $0) })

        return content?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty
            .map(Node.raw)
    }

    func visit(comment nodePointer: UnsafeMutablePointer<xmlNode>?) -> Node? {
        let content = nodePointer?.pointee.content.map({ String(cString: $0) })

        return content.map(Node.comment)
    }
}

private extension AnyIterator {
    init(first: Element?, next: @escaping (Element) -> Element?) {
        var current = first

        self.init {
            defer {
                current = current.flatMap(next)
            }

            return current
        }
    }
}

private extension Collection {
    var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}
