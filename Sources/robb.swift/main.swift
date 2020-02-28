import ArgumentParser
import Foundation

struct Build: ParsableCommand {
    let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    func run() throws {
        print("Building the site.")

        let site = try Site(baseDirectory: path)

        try site.write()
    }
}

struct Sync: ParsableCommand {
    let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    func run() throws {
        let site = try Site(baseDirectory: path)

        let configuration = try JSONDecoder().decode(S3Uploader.Configuration.self, from: Data(contentsOf: path.appendingPathComponent("config.json")))

        print("Building & syncing the site to \(configuration.bucket).")

        try site.sync(configuration: configuration)
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
