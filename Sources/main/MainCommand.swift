import ArgumentParser
import Foundation
import robb_swift

struct Build: ParsableCommand {
    func run() throws {
        print("Building the site.")

        let site = try Site(baseDirectory: Main.path)

        let resources = try Array(site.generate())

        resources
            .concurrentForEach { resource in
                do {
                    try resource.write(relativeTo: site.outputDirectory)
                } catch {
                    print(resource.path, error)
                }
            }
    }
}

struct Sync: AsyncParsableCommand {
    mutating func run() async throws {
        let site = try Site(baseDirectory: Main.path)

        let configuration = try JSONDecoder().decode(S3Uploader.Configuration.self, from: Data(contentsOf: Main.path.appendingPathComponent("config.json")))

        print("Building & syncing the site to \(configuration.bucket).")

        let uploader = S3Uploader(configuration: configuration)

        let resources = try site.generate()

        await withTaskGroup(of: Void.self) { group in
            for resource in resources {
                let _ = group.addTaskUnlessCancelled {
                    try? await uploader.uploadIfNeeded(resource: resource)
                }
            }
        }
    }
}

@main
struct Main: AsyncParsableCommand {
    static let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    static let configuration = CommandConfiguration(
        abstract: "A static site generator for https://robb.is",
        subcommands: [
            Build.self,
            Sync.self
        ],
        defaultSubcommand: Build.self)
}
