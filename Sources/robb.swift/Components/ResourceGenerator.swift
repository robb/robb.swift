import Foundation

protocol ResourceGenerator {
    func generate() throws -> [Resource]
}
