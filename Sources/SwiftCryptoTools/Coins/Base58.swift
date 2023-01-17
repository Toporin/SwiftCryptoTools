import Foundation
import CryptoSwift
//import HsExtensions

public extension HsExtension where Base == String {
    var decodeBase58: Data {
        Base58.decode(base)
    }
}

public extension HsExtension where Base == Data {
    var encodeBase58: String {
        Base58.encode(base)
    }
}

public struct Base58 {
    static let baseAlphabets = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    static var zeroAlphabet: Character = "1"
    static var base: Int = 58

    static func sizeFromByte(size: Int) -> Int {
        size * 138 / 100 + 1
    }
    static func sizeFromBase(size: Int) -> Int {
        size * 733 / 1000 + 1
    }

    static func convertBytesToBase(_ bytes: Data) -> [UInt8] {
        var length = 0
        let size = sizeFromByte(size: bytes.count)
        var encodedBytes: [UInt8] = Array(repeating: 0, count: size)

        for b in bytes {
            var carry = Int(b)
            var i = 0
            for j in (0...encodedBytes.count - 1).reversed() where carry != 0 || i < length {
                carry += 256 * Int(encodedBytes[j])
                encodedBytes[j] = UInt8(carry % base)
                carry /= base
                i += 1
            }

            assert(carry == 0)

            length = i
        }

        var zerosToRemove = 0
        for b in encodedBytes {
            if b != 0 { break }
            zerosToRemove += 1
        }

        encodedBytes.removeFirst(zerosToRemove)
        return encodedBytes
    }
    
    public static func encode(_ bytes: Data) -> String {
        var bytes = bytes
        var zerosCount = 0

        for b in bytes {
            if b != 0 { break }
            zerosCount += 1
        }

        bytes.removeFirst(zerosCount)

        let encodedBytes = convertBytesToBase(bytes)

        var str = ""
        while 0 < zerosCount {
            str += String(zeroAlphabet)
            zerosCount -= 1
        }

        for b in encodedBytes {
            str += String(baseAlphabets[String.Index(utf16Offset: Int(b), in: baseAlphabets)])
        }

        return str
    }

    /**
    * Encodes the given version and bytes as a base58 string. A checksum is appended.
    *
    * @param version the version to encode
    * @param payload the bytes to encode, e.g. pubkey hash
    * @return the base58-encoded string
    */
    public static func encodeChecked(version: UInt8, payload: [UInt8]) -> String {
        // A stringified buffer is:
        // 1 byte version + data bytes + 4 bytes check code (a truncated hash)
        var addressBytes: [UInt8] = [version] + payload
        let checksum: [UInt8] = Digest.sha256(Digest.sha256(addressBytes)) // double sha256
        addressBytes += Array(checksum[0 ..< 4])
        return Base58.encode(Data(addressBytes))
    }
    
    public static func decode(_ string: String) -> Data {
        guard !string.isEmpty else { return Data() }

        var zerosCount = 0
        var length = 0
        for c in string {
            if c != zeroAlphabet { break }
            zerosCount += 1
        }
        let size = sizeFromBase(size: string.lengthOfBytes(using: .utf8) - zerosCount)
        var decodedBytes: [UInt8] = Array(repeating: 0, count: size)
        for c in string {
            guard let baseIndex = baseAlphabets.firstIndex(of: c) else { return Data() }

            var carry = baseIndex.utf16Offset(in: baseAlphabets)
            var i = 0
            for j in (0...decodedBytes.count - 1).reversed() where carry != 0 || i < length {
                carry += base * Int(decodedBytes[j])
                decodedBytes[j] = UInt8(carry % 256)
                carry /= 256
                i += 1
            }

            assert(carry == 0)
            length = i
        }

        // skip leading zeros
        var zerosToRemove = 0

        for b in decodedBytes {
            if b != 0 { break }
            zerosToRemove += 1
        }
        decodedBytes.removeFirst(zerosToRemove)

        return Data(repeating: 0, count: zerosCount) + Data(decodedBytes)
    }
}
