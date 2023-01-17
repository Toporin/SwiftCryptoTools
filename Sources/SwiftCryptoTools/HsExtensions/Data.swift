import Foundation

public extension Data {

    init<T>(from value: T) {
        self = withUnsafePointer(to: value) { (ptr: UnsafePointer<T>) -> Data in
            Data(buffer: UnsafeBufferPointer(start: ptr, count: 1))
        }
    }

}

extension Data: IHsExtension {}

public extension HsExtension where Base == Data {

    var hex: String {
        base.reduce("") {
            $0 + String(format: "%02x", $1)
        }
    }

    var hexString: String {
        "0x" + hex
    }

    var reversedHex: String {
        Data(base.reversed()).hs.hex
    }

    var bytes: Array<UInt8> {
        Array(base)
    }

    func to<T>(type: T.Type) -> T {
        base.withUnsafeBytes { $0.baseAddress!.assumingMemoryBound(to: T.self).pointee }
    }

    func to(type: String.Type) -> String {
        String(bytes: base, encoding: .ascii)!.replacingOccurrences(of: "\0", with: "")
    }

    func to(type: VarInt.Type) -> VarInt {
        let value: UInt64
        let length = base[0..<1].hs.to(type: UInt8.self)
        switch length {
        case 0...252:
            value = UInt64(length)
        case 0xfd:
            value = UInt64(base[1...2].hs.to(type: UInt16.self))
        case 0xfe:
            value = UInt64(base[1...4].hs.to(type: UInt32.self))
        case 0xff:
            fallthrough
        default:
            value = base[1...8].hs.to(type: UInt64.self)
        }
        return VarInt(value)
    }

}
