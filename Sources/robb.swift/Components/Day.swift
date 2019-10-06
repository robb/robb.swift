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

private let humanReadableDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateStyle = .long
    formatter.locale = Locale(identifier: "en-US")
    formatter.timeStyle = .none
    formatter.timeZone = .current

    return formatter
}()

private let isoDateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [ .withFullDate, .withDashSeparatorInDate ]
    formatter.timeZone = .current

    return formatter
}()

func format(_ day: Day, dateFormatter: DateFormatter = humanReadableDateFormatter) -> Node {
    guard let date = dateFormatter.calendar.date(from: day.dateComponents) else {
        return "Unknown Date"
    }

    return time(datetime: isoDateFormatter.string(from: date)) {
        dateFormatter.string(from: date)
    }
}
