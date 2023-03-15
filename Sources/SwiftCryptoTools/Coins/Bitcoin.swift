import Foundation

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
    
}

