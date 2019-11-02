import Foundation
import HTML

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

func format(_ date: Date, dateFormatter: DateFormatter = humanReadableDateFormatter) -> Node {
    time(datetime: isoDateFormatter.string(from: date)) {
        dateFormatter.string(from: date)
    }
}
