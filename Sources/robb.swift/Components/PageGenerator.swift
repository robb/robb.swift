import Foundation

protocol PageGenerator {
    func generate() throws -> [Page]
}
