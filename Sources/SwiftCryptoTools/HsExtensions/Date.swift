import Foundation

extension Date: IHsExtension {}

public extension HsExtension where Base == Date {

    var startOfHour: Date? {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: base)
        return Calendar.current.date(from: components)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: base)
    }

    var startOfMonth: Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)
    }

    func startOfMonth(ago: Int) -> Date? {
        var components = DateComponents()
        components.month = -ago

        guard let startOfMonth = startOfMonth else {
            return nil
        }
        return Calendar.current.date(byAdding: components, to: startOfMonth)
    }

}
