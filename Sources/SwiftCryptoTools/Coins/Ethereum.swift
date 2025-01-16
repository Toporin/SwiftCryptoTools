import Foundation
import CryptoSwift
import BigInt

public class Ethereum: BaseCoin {
    
   
    public override init(isTestnet: Bool, apiKeys: [String: String]){
    
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)
        
        useCompressedAddr = false
        
        // todo: switch to goerli
        if (isTestnet){
            coinSymbol = "ROP"
            displayName = "Ropsten Testnet"
            slip44 = 0x0000003c
        } else{
            coinSymbol = "ETH"
            displayName = "Ethereum"
            slip44 = 0x8000003c
        }
        
        supportToken = true
        supportNft = true
        explorers = [BlockscoutExplorer(coin: self, apiKeys: apiKeys)]
        priceExplorers = [Coingate(coin: self, apiKeys: apiKeys)]
    }
    
    //****************************************
    //*          ENCODING METHODS            *
    //****************************************
    
    public override func pubToAddress(pubkey: [UInt8]) throws -> String {
        var bytes: [UInt8]
        if pubkey.count==64 {
            bytes = pubkey
        } else if pubkey.count==65 {
            // remove first byte
            bytes = Array(pubkey[1 ... 64])
        } else {
            throw CoinError.WrongPubkeySize(length: pubkey.count, expected: 64)
        }
        
        let keccak = SHA3(variant: .keccak256)
        let hash: [UInt8] = keccak.calculate(for: bytes)
        let hash20: [UInt8] = Array(hash.suffix(20)) // last 20 bytes
        let address: String = "0x" + hash20.toHexString()
        return address
        
    }
    
}

