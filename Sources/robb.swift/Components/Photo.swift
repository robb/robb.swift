import Foundation

struct Photo {
    var url: URL

    init?(contentsOf url: URL) {
        guard url.pathExtension == "jpg" else { return nil }

        self.url = url
    }
}
