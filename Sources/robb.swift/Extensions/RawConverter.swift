import HTML

func raw(@NodeBuilder content: () -> NodeConvertible) -> Node {
    RawVisitor().visitNode(content().asNode())
}

private final class RawVisitor: Visitor {
    func visitText(text: String) -> Node {
        .raw(text)
    }
}
