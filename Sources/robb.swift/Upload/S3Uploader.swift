import Foundation
import Logging
import URLRequest_AWS

struct HTTPError: Error {
    var data: Data?

    var response: HTTPURLResponse
}

public final class S3Uploader {
    public static let defaultLogger: Logger = {
        var logger = Logger(label: "is.robb.website.upload")
        logger.logLevel = .notice

        return logger
    }()

    public struct Configuration: Codable {
        public var bucket: String

        public var credentials: Credentials

        public var region: String
    }

    let configuration: Configuration

    let logger: Logger

    let urlSession: URLSession

    public init(configuration: Configuration, logger: Logger = S3Uploader.defaultLogger) {
        self.configuration = configuration

        self.logger = logger

        let config = URLSessionConfiguration.ephemeral
        config.httpShouldUsePipelining = true
        config.httpMaximumConnectionsPerHost = 30

        self.urlSession = URLSession(configuration: config)
    }

    @discardableResult
    private func performRequest(_ request: URLRequest) async throws -> (Data?, HTTPURLResponse) {
        struct UnexpectedStateError: Error {}

        var copy = request

        copy.sign(credentials: configuration.credentials, region: configuration.region, service: "s3")

        let (data, response) = try await self.urlSession.data(for: copy)

        switch (data, response) {
        case let (data, response as HTTPURLResponse):
            if response.statusCode < 400 {
                return (data, response)
            } else {
                throw HTTPError(data: data, response: response)
            }
        default:
            throw UnexpectedStateError()
        }
    }
}

extension S3Uploader {
    private func urlForResource(_ resource: Resource) -> URL {
        URL(string: "http://\(configuration.bucket).s3.amazonaws.com")! / resource.s3Path
    }

    private func fileExists(resource: Resource) async throws -> Bool {
        let url = urlForResource(resource)

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.setValue(resource.data.md5Hash().hexEncodedString(), forHTTPHeaderField: "If-None-Match")

        do {
            let (_, response) = try await performRequest(request)

            return response.statusCode == 304
        } catch where error is HTTPError {
            return false
        }
    }

    private func updateMetadata(resource: Resource) async throws {
        let url = urlForResource(resource)

        let copySource = configuration.bucket +
            (resource.s3Path.first == "/" ? "" : "/") +
            resource.s3Path

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("REPLACE", forHTTPHeaderField: "x-amz-metadata-directive")
        request.setValue(copySource.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!, forHTTPHeaderField: "x-amz-copy-source")
        request.setValue(resource.cacheControl, forHTTPHeaderField: "Cache-Control")
        request.setValue(resource.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(resource.storageClass, forHTTPHeaderField: "x-amz-storage-class")

        self.logger.info("Updating metadata for \(resource.s3Path)")

        try await performRequest(request)
    }

    private func setupRedirect(resource: Resource) async throws {
        guard resource.requiresRedirect else { return }

        let url = urlForResource(resource)

        var redirectRequest = URLRequest(url: url / "index.html")
        redirectRequest.httpMethod = "PUT"
        redirectRequest.setValue(resource.s3Path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed), forHTTPHeaderField: "x-amz-website-redirect-location")

        self.logger.info("Setting up redirect for \(resource.s3Path)")

        try await performRequest(redirectRequest)
    }

    private func upload(resource: Resource) async throws {
        let url = urlForResource(resource)

        var putRequest = URLRequest(url: url)
        putRequest.httpBody = resource.data
        putRequest.httpMethod = "PUT"
        putRequest.setValue(resource.cacheControl, forHTTPHeaderField: "Cache-Control")
        putRequest.setValue(resource.contentType, forHTTPHeaderField: "Content-Type")
        putRequest.setValue(resource.data.md5Hash().base64EncodedString(), forHTTPHeaderField: "Content-MD5")
        putRequest.setValue(resource.storageClass, forHTTPHeaderField: "x-amz-storage-class")

        self.logger.notice("Uploading \(resource.s3Path)")

        try await performRequest(putRequest)
    }

    public func uploadIfNeeded(resource: Resource) async throws {
        if try await fileExists(resource: resource) {
            try await updateMetadata(resource: resource)
        } else {
            try await upload(resource: resource)
        }

        try await setupRedirect(resource: resource)
    }
}

private extension Resource {
    var cacheControl: String? {
        guard contentType?.hasPrefix("image/") ?? false else { return nil }

        return "max-age=1209600,public"
    }

    var requiresRedirect: Bool {
        contentType == "text/html" && path != "/"
    }

    var s3Path: String {
        if contentType == "text/html" && path == "/" {
            return "/index.html"
        }

        return path
    }

    var storageClass: String {
        return "STANDARD"
    }
}
