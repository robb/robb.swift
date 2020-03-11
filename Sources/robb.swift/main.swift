import ArgumentParser
import Foundation

struct Build: ParsableCommand {
    let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    func run() throws {
        print("Building the site.")

        let site = try Site(baseDirectory: path)

        try site
            .generate()
            .concurrentForEach { resource in
                do {
                    try resource.write(relativeTo: site.outputDirectory)
                } catch {
                    print(resource.path, error)
                }
            }
    }
}

struct Sync: ParsableCommand {
    let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    func run() throws {
        let site = try Site(baseDirectory: path)

        let configuration = try JSONDecoder().decode(S3Uploader.Configuration.self, from: Data(contentsOf: path.appendingPathComponent("config.json")))

        print("Building & syncing the site to \(configuration.bucket).")

        let uploader = S3Uploader(configuration: configuration)

        let group = DispatchGroup()

        try site
            .generate()
            .concurrentForEach { resource in
                group.enter()
                uploader
                    .uploadIfNeeded(resource: resource)
                    .done { result in
                        group.leave()
                    }
            }

        group.wait()
    }
}

struct Main: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A static site generator for https://robb.is",
        subcommands: [
            Build.self,
            Sync.self
        ])
}

Main.main()
