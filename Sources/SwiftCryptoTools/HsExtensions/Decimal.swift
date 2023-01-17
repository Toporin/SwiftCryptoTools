import Foundation

extension Decimal: IHsExtension {}

public extension HsExtension where Base == Decimal {

    var integerDigitCount: Int {
        var value = abs(base)
        var count = 1
        while value >= 10 {
            value /= 10
            count += 1
        }
        return count
    }

    var decimalCount: Int {
        max(-base.exponent, 0)
    }

    func significandDigits(fractionDigits: Int) -> Int {
        let integerDigits = base.significand.description.count + base.exponent
        return integerDigits + fractionDigits
    }

    func rounded(decimal: Int) -> Decimal {
        let poweredDecimal = base * pow(10, decimal)
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        return NSDecimalNumber(decimal: poweredDecimal).rounding(accordingToBehavior: handler).decimalValue
    }

    func roundedString(decimal: Int) -> String {
        String(describing: rounded(decimal: decimal))
    }

}
