import Foundation

extension String: IHsExtension {}

public extension HsExtension where Base == String {

    func stripHexPrefix() -> String {
        let prefix = "0x"

        if base.hasPrefix(prefix) {
            return String(base.dropFirst(prefix.count))
        }

        return base
    }

    func addHexPrefix() -> String {
        let prefix = "0x"

        if base.hasPrefix(prefix) {
            return base
        }

        return prefix.appending(base)
    }

    func removeLeadingZeros() -> String {
        base == "0" ? base : base.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
    }

    var hexData: Data? {
        let hex = base.hs.stripHexPrefix()

        let len = hex.count / 2
        var data = Data(capacity: len)
        var s = ""

        for c in hex {
            s += String(c)
            if s.count == 2 {
                if var num = UInt8(s, radix: 16) {
                    data.append(&num, count: 1)
                    s = ""
                } else {
                    return nil
                }
            }
        }
        return data
    }

    var reversedHexData: Data? {
        self.hexData.map { Data($0.reversed()) }
    }

    var data: Data {
        base.data(using: .utf8) ?? Data()
    }

}
