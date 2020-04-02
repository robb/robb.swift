import Foundation

extension Date {
    init?(filename: String) {
        var year = 0, month = 0, day = 0

        let scanner = Scanner(string: filename)

        guard scanner.scanInt(&year)
            && scanner.scanString("-") != nil
            && scanner.scanInt(&month)
            && scanner.scanString("-") != nil
            && scanner.scanInt(&day) else {
                return nil
        }

        let components = DateComponents(year: year, month: month, day: day)

        if let date = Calendar(identifier: .gregorian).date(from: components) {
            self = date
        } else {
            return nil
        }
    }
}
