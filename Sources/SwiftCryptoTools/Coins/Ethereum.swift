import Foundation
import CryptoSwift
import BigInt

public class Ethereum: BaseCoin {
    
   
    public override init(isTestnet: Bool, apiKeys: [String: String]){
    
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)
        
        useCompressedAddr = false
        
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
        blockExplorer = Etherscan(coinSymbol: coinSymbol, apiKeys: apiKeys)
        nftExplorer = Rarible(coinSymbol: self.coinSymbol, apiKeys: apiKeys) // opensea or rarible
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
    
    public override func contractBytesToString(contractBytes: [UInt8]) -> String {
        let contractString = "0x" + contractBytes.toHexString()
        return contractString
    }
    
    public override func tokenidBytesToString(tokenidBytes: [UInt8]) -> String {
        
        // debug
        let uint1: [UInt8] = [0x0, 0x0, 0x0, 0x1]
        let bigint1 = BigUInt(Data(uint1))
        print("DEBUG bigint1: \(bigint1.description)")
        print("DEBUG bigint1: \(bigint1)")
        
        let uint2: [UInt8] = [0x1, 0x0, 0x0, 0x0]
        let bigint2 = BigUInt(Data(uint2))
        print("DEBUG bigint2: \(bigint2.description)")
        print("DEBUG bigint2: \(bigint2)")
        //endbug
        
        let biguint: BigUInt = BigUInt(Data(tokenidBytes))
        print("biguint: \(biguint.description)")
        return biguint.description
    }
    
}

