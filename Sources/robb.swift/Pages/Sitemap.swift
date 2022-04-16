import Foundation
import HTML

struct Sitemap: Page {
    static let defaultLayout: Layout = .empty

    let baseURL: URL

    let contentType = "application/xml"

    let pathComponents = [ "sitemap.xml" ]

    let pages: [Page]

    let title = "Sitemap"

    func content() -> Node {
        urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") {
            pages
                .sorted(by: \.path)
                .map { page in
                    url {
                        loc {
                            baseURL.appendingPathComponent(page.path)
                        }
                        changefreq {
                            "weekly"
                        }
                    }
                }
        }
    }
}

extension Sitemap {
    private func urlset(xmlns: String, @NodeBuilder children: () -> NodeConvertible) -> Node {
        .element("urlset", [ "xmlns": xmlns ], children().asNode())
    }

    private func url(@NodeBuilder children: () -> NodeConvertible) -> Node {
        .element("url", [:], children().asNode())
    }

    private func loc(url: () -> URL) -> Node {
        .element("loc", [:], %.text(url().absoluteString)%)
    }

    private func changefreq(frequency: () -> String) -> Node {
        .element("changefreq", [:], %frequency().asNode()%)
    }
}
