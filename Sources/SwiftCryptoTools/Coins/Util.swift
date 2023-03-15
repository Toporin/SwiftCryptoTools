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
        return hexString
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

//extension String {
//    func matches(regex: String) -> Bool {
//        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
//    }
//}

//extension String {
//    func matches(regex: String) -> Bool {
//        let regexObject = try! NSRegularExpression(pattern: regex)
//        return regexObject.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
//    }
//}

extension String {
    func matches(pattern: String) -> Bool {
        //let pattern2 = #"^(0x)?[a-fA-F0-9]{40}$"# //#"^0x[a-fA-F0-9]{40}$"#
        //print("pattern: \(pattern)")
        //print("pattern2: \(pattern2)")
        let regex = try! NSRegularExpression(pattern: pattern)
        //let testString = self // #"0xeB7C917821796eb627C0719A23a139ce51226CD2"#
        //print("String to eval: \(self)")
        let stringRange = NSRange(location: 0, length: self.utf16.count)
        let firstmatch = regex.firstMatch(in: self, range: stringRange)
        //print("firstmatch: \(firstmatch)")
        
//        let matches = regex.matches(in: self, range: stringRange)
//        print("matches: \(matches)")
//        var result: [[String]] = []
//        for match in matches {
//            print("match: \(match)")
//            var groups: [String] = []
//            for rangeIndex in 1 ..< match.numberOfRanges {
//                let nsRange = match.range(at: rangeIndex)
//                guard !NSEqualRanges(nsRange, NSMakeRange(NSNotFound, 0)) else { continue }
//                let string = (self as NSString).substring(with: nsRange)
//                groups.append(string)
//            }
//            if !groups.isEmpty {
//                result.append(groups)
//            }
//        }
//        print("result: \(result)")
//        return matches.count>0
        return firstmatch != nil
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
