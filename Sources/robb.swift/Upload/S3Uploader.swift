import Foundation
import Future
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

    private func performRequest(_ request: URLRequest) -> Future<(data: Data?, response: HTTPURLResponse), Error> {
        struct UnexpectedStateError: Error {}

        var copy = request

        copy.sign(credentials: configuration.credentials, region: configuration.region, service: "s3")

        return Future { resolve in
            let task = self.urlSession.dataTask(with: copy) { data, response, error in
                let result: Result<(data: Data?, response: HTTPURLResponse), Error>

                defer {
                    resolve(result)
                }

                switch (data, response, error) {
                case let (data, response as HTTPURLResponse, _):
                    if response.statusCode < 400 {
                        result = .success((data, response))
                    } else {
                        result = .failure(HTTPError(data: data, response: response))
                    }
                case let (_, _, error?):
                    result = .failure(error)
                default:
                    result = .failure(UnexpectedStateError())
                }
            }

            task.resume()
        }
    }
}

extension S3Uploader {
    private func urlForResource(_ resource: Resource) -> URL {
        URL(string: "http://\(configuration.bucket).s3.amazonaws.com")! / resource.s3Path
    }

    private func fileExists(resource: Resource) -> Future<Bool, Error> {
        let url = urlForResource(resource)

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.setValue(resource.data.md5Hash().hexEncodedString(), forHTTPHeaderField: "If-None-Match")

        return performRequest(request)
            .map { result in
                result.response.statusCode == 304
            }
            .flatMapError { _ in
                Future(value: false)
            }
    }

    private func updateMetadata(resource: Resource) -> Future<Void, Error> {
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

        return performRequest(request)
            .map { _ in }
            .do {
                self.logger.info("Updating metadata for \(resource.s3Path)")
            }
    }

    private func setupRedirect(resource: Resource) -> Future<Void, Error> {
        guard resource.requiresRedirect else { return Future() }

        let url = urlForResource(resource)

        var redirectRequest = URLRequest(url: url / "index.html")
        redirectRequest.httpMethod = "PUT"
        redirectRequest.setValue(resource.s3Path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed), forHTTPHeaderField: "x-amz-website-redirect-location")

        return performRequest(redirectRequest)
            .map { _ in }
            .do {
                self.logger.info("Setting up redirect for \(resource.s3Path)")
            }
    }

    private func upload(resource: Resource) -> Future<Void, Error> {
        let url = urlForResource(resource)

        var putRequest = URLRequest(url: url)
        putRequest.httpBody = resource.data
        putRequest.httpMethod = "PUT"
        putRequest.setValue(resource.cacheControl, forHTTPHeaderField: "Cache-Control")
        putRequest.setValue(resource.contentType, forHTTPHeaderField: "Content-Type")
        putRequest.setValue(resource.data.md5Hash().base64EncodedString(), forHTTPHeaderField: "Content-MD5")
        putRequest.setValue(resource.storageClass, forHTTPHeaderField: "x-amz-storage-class")

        return performRequest(putRequest)
            .map { _ in }
            .do {
                self.logger.notice("Uploading \(resource.s3Path)")
            }
    }

    public func uploadIfNeeded(resource: Resource) -> Future<Void, Error> {
        let uploadTask = upload(resource: resource)
        let updateMetadataTask = updateMetadata(resource: resource)
        let setupRedirectTask = setupRedirect(resource: resource)

        return self
            .fileExists(resource: resource)
            .flatMap { alreadyExists in
                alreadyExists ? updateMetadataTask : uploadTask
            }
            .flatMap {
                setupRedirectTask
            }
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

extension Future {
    func `do`(_ function: @escaping (Success) -> Void) -> Future<Success, Failure> {
        map {
            function($0)

            return $0
        }
    }
}
