import Foundation

public struct Resource: Hashable {
    private enum Backing: Hashable {
        case data(Data)
        case file(URL)
    }

    private var backing: Backing

    public var contentType: String?

    public var path: String

    public var data: Data {
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
        self.contentType = url.mimeType
        self.path = path
    }
}

extension Resource {
    public func write(relativeTo outputDirectory: URL, fileManager: FileManager = .default) throws {
        var file = outputDirectory / path

        if contentType == "text/html" {
            file.appendPathComponent("index.html")
        }

        try fileManager.createDirectory(
            at: file.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try write(to: file)
    }

    public func write(to url: URL, fileManager: FileManager = .default) throws {
        switch backing {
        case let .data(data):
            try data.write(to: url)
        case let .file(source):
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }

            try fileManager.copyItem(at: source, to: url)
        }
    }
}

extension Resource: TextOutputStreamable {
    public func write<Target>(to target: inout Target) where Target: TextOutputStream {
        guard let string = String(data: data, encoding: .utf8) else { return }

        target.write(string)
    }
}
