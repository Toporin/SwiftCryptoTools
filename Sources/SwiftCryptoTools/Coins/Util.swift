import Foundation
import CryptoSwift

extension Array where Element == UInt8 {
    var bytesToHex: String {
        var hexString: String = ""
        var count = self.count
        for byte in self
        {
            hexString.append(String(format:"%02X", byte))
            count = count - 1
        }
        return hexString // letters in uppercase
    }
}

extension Collection where Element == Character {
    var hexToBytes: [UInt8] {
        var last = first
        return dropFirst().compactMap {
            guard
                let lastHexDigitValue = last?.hexDigitValue,
                let hexDigitValue = $0.hexDigitValue else {
                    last = $0
                    return nil
                }
            defer {
                last = nil
            }
            return UInt8(lastHexDigitValue * 16 + hexDigitValue)
        }
    }
}

class Util {
    static let shared = Util()
    
    private init() {}
    
    
    // Calculates RIPEMD160(SHA256(input)). This is used in Address calculations.
    public func sha256hash160(data: [UInt8]) -> [UInt8] {
        let sha256Bytes = Digest.sha256(data)
        let ripemd160Bytes = RIPEMD160.hash(Data(sha256Bytes))
        return ripemd160Bytes.bytes
    }
}
