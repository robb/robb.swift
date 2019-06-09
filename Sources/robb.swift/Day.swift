import Foundation
import HTML

struct Day: Equatable {
    var year: Int
    var month: Int
    var day: Int
}

extension Day: Comparable {
    static func < (lhs: Day, rhs: Day) -> Bool {
        return lhs.year < rhs.year
            || lhs.year == rhs.year && lhs.month < rhs.month
            || lhs.year == rhs.year && lhs.month == rhs.month && lhs.day < rhs.day
    }
}

private extension Day {
    var dateComponents: DateComponents {
        DateComponents(year: year, month: month, day: day)
    }
}

private let defaultDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateStyle = .medium
    formatter.locale = Locale(identifier: "en-US")
    formatter.timeStyle = .none

    return formatter
}()

func format(_ day: Day, dateFormatter: DateFormatter = defaultDateFormatter) -> Node {
    guard let date = dateFormatter.calendar.date(from: day.dateComponents) else {
        return Text(value: "Unknown Date")
    }

    // TODO: Add `datetime` attribute
    return time {
        dateFormatter.string(from: date)
    }
}
