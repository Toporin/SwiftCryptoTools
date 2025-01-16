import Foundation

public class BitcoinCash: Bitcoin {
    
    var cashAddrPrefix: String
    var simpleledgerPrefix: String
    var cashAddressTypePubkey = 0
    var cashAddressTypeScript = 1
    
    public override init(isTestnet: Bool, apiKeys: [String: String]){
        
        cashAddrPrefix = "bitcoincash"
        simpleledgerPrefix = "simpleledger"
        
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)
        
        supportSegwit = false
        if self.isTestnet {
            coinSymbol = "BCHTEST"
            displayName = "Bitcoin Cash Testnet"
            slip44 = 0x00000091
            magicbyte = 111
            scriptMagicbyte = 196
            segwitHrp = "tb"
            cashAddrPrefix = "bchtest"
            simpleledgerPrefix = "slptest"
        } else {
            coinSymbol = "BCH"
            displayName = "Bitcoin Cash"
            slip44 = 0x80000091
            magicbyte = 0
            scriptMagicbyte = 5
            segwitHrp = "bc"
        }
        
        explorers = [FullstackExplorer(coin: self, apiKeys: apiKeys)]
        priceExplorers = [Coingate(coin: self, apiKeys: apiKeys), Coingecko(coin: self, apiKeys: apiKeys)]
    }
    
    //****************************************
    //*          ENCODING METHODS            *
    //****************************************
    
    public override func pubToAddress(pubkey: [UInt8]) throws -> String {
        //print("in BitcoinCash pubToAddress pubkey: \(pubkey.bytesToHex)")
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
        
        let pubkeyHash: [UInt8] = Util.shared.sha256hash160(data: bytes)
        
        // https://github.com/horizontalsystems/BitcoinCashKit.Swift/blob/master/Sources/BitcoinCashKit/Classes/Bech32/CashBech32AddressConverter.swift
        var addressType: UInt8 = 0 //addressType.rawValue for pubKeyHash = 0
        // make version byte use rules in convert address method
        let sizeOffset = pubkeyHash.count >= 40
        let divider = sizeOffset ? 8 : 4
        let size = pubkeyHash.count - (sizeOffset ? 20 : 0) - 20
        let versionByte = addressType + (sizeOffset ? 1 : 0) << 2 + UInt8(size / divider)
        //print("versionByte: \(versionByte)")
        let cashAddress = CashAddrBech32.encode(Data([versionByte]) + Data(pubkeyHash), prefix: cashAddrPrefix)
        return cashAddress
    }
    
}

