import Foundation

public struct Resource {
    private enum Backing {
        case data(Data)
        case file(URL)
    }

    private var backing: Backing

    var contentType: String?

    var path: String

    var data: Data {
        switch backing {
        case let .data(data):
            return data
        case let .file(url):
            return (try? Data(contentsOf: url)) ?? Data()
        }
    }

    public init(contentType: String?, path: String, data: Data) {
        self.backing = .data(data)
        self.contentType = contentType
        self.path = path
    }

    public init(path: String, url: URL) {
        self.backing = .file(url)
        self.path = path

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil)?.takeUnretainedValue(),
           let mime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType) {
            self.contentType = String(mime.takeUnretainedValue())
        }
    }
}

extension Resource {
    public func write(to url: URL) throws {
        switch backing {
        case let .data(data):
            try data.write(to: url)
        case let .file(source):
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }

            try FileManager.default.copyItem(at: source, to: url)
        }
    }
}

extension Resource: TextOutputStreamable {
    public func write<Target>(to target: inout Target) where Target: TextOutputStream {
        guard let string = String(data: data, encoding: .utf8) else { return }

        target.write(string)
    }
}
