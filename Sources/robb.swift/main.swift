import Foundation
import HTML

let site = try Site(baseDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))

try site.build()
