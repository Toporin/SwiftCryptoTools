import Foundation
import CryptoSwift

public class Bitcoin: BaseCoin {
    
    var magicbyte: UInt8
    var scriptMagicbyte: UInt32
    var segwitHrp: String
    var supportSegwit: Bool = true
    //var wifPrefix: UInt8

    public override init(isTestnet: Bool, apiKeys: [String: String]){
        // bitcoin mainnet params
        magicbyte = 0
        scriptMagicbyte = 5
        segwitHrp = "bc"
        
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)

        if isTestnet {
            coinSymbol = "BTCTEST"
            displayName = "Bitcoin Testnet"
            slip44 = 0x00000000
            magicbyte = 111
            scriptMagicbyte = 196
            segwitHrp = "tb"
        } else {
            coinSymbol = "BTC"
            displayName = "Bitcoin"
            slip44 = 0x80000000
        }
        
        blockExplorer = Blockstream(coinSymbol: coinSymbol, apiKeys: apiKeys)
        priceExplorer = Coingecko(coinSymbol: coinSymbol, isTestnet: isTestnet, apiKeys: apiKeys)
    }
    
    //****************************************
    //*          ENCODING METHODS            *
    //****************************************
    
    public override func pubToAddress(pubkey: [UInt8]) throws -> String {
        var bytes: [UInt8]
        if useCompressedAddr {
            if pubkey.count==65 {
                // compress pubkey
                let parity = pubkey[64]%2
                bytes = Array(pubkey[0 ... 32])
                bytes[0] = (parity==0) ? UInt8(0x02) : UInt8(0x03)
            } else if pubkey.count == 33 {
                bytes = pubkey
            } else {
                throw CoinError.WrongPubkeySize(length: pubkey.count, expected: 33)
            }
        } else {
            if pubkey.count==65 {
                bytes = pubkey
            } else {
                throw CoinError.WrongPubkeySize(length: pubkey.count, expected: 65)
            }
        }
        
        // by default, return segwit address if supported
        if supportSegwit {
            return try pubToSegwitAddress(pubkey: bytes)
        } else {
            return try pubToLegacyAddress(pubkey: bytes)
        }
    }
    
    public func pubToLegacyAddress(pubkey: [UInt8]) throws -> String {
        let pubkeyHash: [UInt8] = Util.shared.sha256hash160(data: pubkey)
        return Base58.encodeChecked(version: magicbyte, payload: pubkeyHash)
    }
    
    public func pubToSegwitAddress(pubkey: [UInt8]) throws -> String {
        let witnessVersion: UInt8=0
        let pubkeyHash: [UInt8] = Util.shared.sha256hash160(data: pubkey)
        let encoded = try SegWitBech32.encode(hrp: segwitHrp, version: witnessVersion, program: Data(pubkeyHash))
        print("pubToSegwitAddress encoded: \(encoded)")
        return encoded
    }
    
    //****************************************
    //*          SCRIPT ENCODING             *
    //****************************************
    
    /*
     Convert a hash to the new segwit address format outlined in BIP-0173
     */
    public func hashToSegwitAddr(hash: [UInt8]) throws -> String {
        let encoded = try SegWitBech32.encode(hrp: segwitHrp, version: 0, program: Data(hash))
        print("hashToSegwitAddr encoded: \(encoded)")
        return encoded
    }
    
    /*
     Convert a script to the new segwit address format outlined in BIP01743
    */
    public func scriptToP2wsh(script: [UInt8]) throws -> String {
        let hashBytes = Digest.sha256(script)
        return try self.hashToSegwitAddr(hash: hashBytes)
    }
    /*
      Convert an output p2sh script to an address
     */
    public func p2shScriptToAddr(script: [UInt8]) -> String {
        
        let hash160Bytes = Util.shared.sha256hash160(data: script)
        let addr = Base58.encodeChecked(version: UInt8(self.scriptMagicbyte), payload: hash160Bytes)
        return addr
        //return hex_to_b58check(hash160(script), self.scriptMagicbyte)
    }
    
    /*
    Convert an input public key hash to an address
    */
    public func scriptToAddr(script: [UInt8]) -> String {
        let addr: String
        let scriptHex = script.bytesToHex
        print("scriptHex: \(scriptHex)")
        print("script.count: \(script.count)")
        if scriptHex.hasPrefix("76A914") && scriptHex.hasSuffix("88AC") && script.count == 25 {
            print("scriptToAddr P2PKH")
            var scriptTrimmed = Array(script.dropFirst(3))
            scriptTrimmed = Array(scriptTrimmed.dropLast(2))
            addr = Base58.encodeChecked(version: UInt8(self.magicbyte), payload: scriptTrimmed)
        }
        else {
            // BIP0016 scripthash addresses
            print("scriptToAddr P2SH")
            var scriptTrimmed = Array(script.dropFirst(2))
            scriptTrimmed = Array(scriptTrimmed.dropLast(1))
            addr = Base58.encodeChecked(version: UInt8(self.scriptMagicbyte), payload: scriptTrimmed)
        }
        return addr
//        if (Array(script[..<3]) == "76a914".hexToBytes) && (Array(script[-2...]) == "88ac".hexToBytes) && script.count == 25 {}
//        if script[:3] == b'\x76\xa9\x14' and script[-2:] == b'\x88\xac' and len(script) == 25:
//                return bin_to_b58check(script[3:-2], self.magicbyte)  # pubkey hash addresses
//        else:
//                return bin_to_b58check(script[2:-1], self.script_magicbyte)
    }
    
    
}

