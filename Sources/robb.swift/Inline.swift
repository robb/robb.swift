import Foundation
import HTML

func inline(file path: String) -> Node {
    let resourceFolder = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true).appendingPathComponent("Resources")

    let url = URL(fileURLWithPath: path, relativeTo: resourceFolder)

    return try! Text(value: String(contentsOf: url))
}
