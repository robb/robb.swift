import Foundation
import Future

public extension Array {
    func concurrentMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
        let intermediate = Atomic(Array<B?>(repeating: nil, count: count))

        DispatchQueue.concurrentPerform(iterations: count) { i in
            let transformed = transform(self[i])

            intermediate.atomically {
                $0[i] = transformed
            }
        }

        return intermediate.atomically {
            $0.map { $0! }
        }
    }

    func concurrentForEach(_ body: (Self.Element) -> Void) {
        DispatchQueue.concurrentPerform(iterations: count) { i in
            let value = self[i]

            body(value)
        }
    }
}
