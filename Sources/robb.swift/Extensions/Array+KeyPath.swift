import Foundation

extension Array {
    func max<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Element? {
        self.max { a, b in
            a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }

    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        self.sorted { a, b in
            a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}
