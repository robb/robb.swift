import Foundation
import HTML

struct Gallery: Page {
    var title: String

    var pathComponents: [String] {
        ["taking-pictures", title]
    }

    var photos: [Photo]

    init(directory: URL) {
        title = directory.lastPathComponent
        photos = (try? Photo.photos(in: directory)) ?? []
    }

    func content() -> Node {
        [
            DependencyFilter.dependency(stylesheet: "/css/gallery.css"),
            DependencyFilter.dependency(javascript: "/js/loading-attribute-polyfill.min.js", async: false),
            h1 {
                title
            },
            .fragment(photos.map { photo in
                noscript(class: "loading-lazy") {
                    img(class: "gallery-photo", loading: "lazy", src: photo.url.absoluteString)
                }
            })
        ]
    }
}

extension Photo {
    static func photos(in directory: URL) throws -> [Photo] {
        return try FileManager.default
            .contentsOfDirectory(atPath: directory.path)
            .map { directory / $0 }
            .concurrentMap(Photo.init)
            .compactMap { $0 }
            .sorted { a, b in
                a.url.absoluteString < b.url.absoluteString
            }
    }
}
