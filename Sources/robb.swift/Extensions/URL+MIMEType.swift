import Foundation

extension URL {
    var mimeType: String? {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeUnretainedValue(),
           let mime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType) {
            return String(mime.takeUnretainedValue())
        }

        return nil
    }
}
