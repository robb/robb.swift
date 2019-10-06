import Foundation

let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

let site = try Site(baseDirectory: path)



switch CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : nil {
case "build":
    print("Building site")

    try site.write()
case "sync":
    let configuration = try JSONDecoder().decode(S3Uploader.Configuration.self, from: Data(contentsOf: path.appendingPathComponent("config.json")))

    print("Building, syncing to \(configuration.bucket)")

    try site.sync(configuration: configuration)
default:
    print("""
    Possible commands:

    build

    sync
    """)
}
