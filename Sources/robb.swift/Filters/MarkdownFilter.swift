import Foundation
import HTML
import cmark_gfm
import cmark_gfm_extensions
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
        guard isInsideMarkdownTag else { return .text(text) }

        return MarkdownFilter.render(text) ?? ""
    }

    func visitRaw(raw: String) -> Node {
        guard isInsideMarkdownTag else { return .raw(raw) }

        return MarkdownFilter.render(raw) ?? ""
    }
}

private final class MarkdownParser {
    private var root: UnsafeMutablePointer<cmark_node>?

    var footnoteIndex = 1

    lazy var documentID: UUID = UUID()

    init(document: String) {
        cmark_gfm_core_extensions_ensure_registered()

        let parser = cmark_parser_new(CMARK_OPT_FOOTNOTES)
        cmark_parser_attach_syntax_extension(parser, cmark_find_syntax_extension("strikethrough"))

        cmark_parser_feed(parser, document, document.utf8.count)

        root = cmark_parser_finish(parser)
    }

    deinit {
        cmark_node_free(root)
    }

    func parse() -> Node? {
        root.flatMap(visitNode)
    }

    func visitNode(_ node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        if cmark_node_get_type(node) == CMARK_NODE_FOOTNOTE_DEFINITION {
            return visit(footnoteDefinition: node)
        }

        if cmark_node_get_type(node) == CMARK_NODE_FOOTNOTE_REFERENCE {
            return visit(footnoteReference: node)
        }

        switch String(cString: cmark_node_get_type_string(node)) {
        case "document":       return visit(document: node)
        case "block_quote":    return visit(blockQuote: node)
        case "list":           return visit(list: node)
        case "item":           return visit(item: node)
        case "code_block":     return visit(codeBlock: node)
        case "html_block":     return visit(htmlBlock: node)
        case "custom_block":   return visit(customBlock: node)
        case "paragraph":      return visit(paragraph: node)
        case "heading":        return visit(heading: node)
        case "thematic_break": return visit(thematicBreak: node)

        case "text":           return visit(text: node)
        case "softbreak":      return visit(softBreak: node)
        case "linebreak":      return visit(lineBreak: node)
        case "code":           return visit(code: node)
        case "html_inline":    return visit(htmlInline: node)
        case "custom_inline":  return visit(customInline: node)
        case "emph":           return visit(emphasis: node)
        case "strong":         return visit(strong: node)
        case "link":           return visit(link: node)
        case "image":          return visit(image: node)

        case "strikethrough":  return visit(strikethrough: node)

        case "attribute":           return visit(attribute: node)
        default:
            fatalError("Unhandled node type: \(String(cString: cmark_node_get_type_string(node)))")
        }
    }

    func visitChildren(of node: UnsafeMutablePointer<cmark_node>?) -> [Node] {
        let iterator = AnyIterator(first: cmark_node_first_child(node), next: cmark_node_next)

        return iterator.compactMap(visitNode)
    }

    func visit(document node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        .fragment(visitChildren(of: node))
    }

    func visit(blockQuote node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        blockquote {
            visitChildren(of: node)
        }
    }

    func visit(list node: UnsafeMutablePointer<cmark_node>?) -> Node? {
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

    func visit(item node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        li {
            visitChildren(of: node)
        }
    }

    func visit(codeBlock node: UnsafeMutablePointer<cmark_node>?) -> Node? {
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

    func visit(htmlBlock node: UnsafeMutablePointer<cmark_node>?) -> Node? {
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

    func visit(customBlock node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        fatalError("What is a CustomBlock?")
    }

    func visit(paragraph node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        p {
            visitChildren(of: node)
        }
    }

    func visit(heading node: UnsafeMutablePointer<cmark_node>?) -> Node? {
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

    func visit(thematicBreak node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        hr()
    }

    func visit(text node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        return .raw(content)
    }

    func visit(softBreak node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        .text("")
    }

    func visit(lineBreak node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        br()
    }

    func visit(code node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        return %code { content.addingXMLEncoding() }%
    }

    func visit(htmlInline node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        let content = String(cString: cmark_node_get_literal(node))

        return .raw(content)
    }

    func visit(customInline node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        fatalError("What is a CustomInline?")
    }

    func visit(emphasis node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        %em {
            visitChildren(of: node)
        }%
    }

    func visit(strong node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        %strong {
            visitChildren(of: node)
        }%
    }

    func visit(link node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        let url = String(cString: cmark_node_get_url(node))
        let title = String(cString: cmark_node_get_title(node))

        return %a(href: url, title: title.nilIfEmpty) {
            visitChildren(of: node)
        }%
    }

    func visit(image node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        let url = String(cString: cmark_node_get_url(node))
        let title = String(cString: cmark_node_get_title(node))

        return img(src: url, title: title.nilIfEmpty)
    }

    func visit(strikethrough node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        %s {
            visitChildren(of: node)
        }%
    }

    func visit(footnoteDefinition node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        defer {
            footnoteIndex += 1
        }

        let label = String(footnoteIndex)

        return div(id: "footnote-\(documentID.uuidString)-\(label)") {
            %a(href: "#footnote-\(documentID.uuidString)-ref-\(label)") {
                %.text(label)%
            } %% ":"

            visitChildren(of: node)
        }
    }

    func visit(footnoteReference node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        guard let literal = cmark_node_get_literal(node) else { return nil }

        let label = String(cString: literal)

        return %sup {
            %a(href: "#footnote-\(documentID.uuidString)-\(label)", id: "footnote-\(documentID.uuidString)-ref-\(label)") {
                %.text(label)%
            }%
        }%
    }

    func visit(attribute node: UnsafeMutablePointer<cmark_node>?) -> Node? {
        if let attributes = cmark_node_get_attributes(node) {
            print(String(cString: attributes))
        }

        return .fragment(visitChildren(of: node))
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
            .map(Node.text)
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
