import Foundation
import CryptoSwift
import BigInt

// Polygon: Changer nom, slip44, blockExplorer

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
        //blockExplorer = Etherscan(coinSymbol: coinSymbol, apiKeys: apiKeys)
        blockExplorer = Ethplorer(coinSymbol: coinSymbol, apiKeys: apiKeys)
        nftExplorer = Rarible(coinSymbol: self.coinSymbol, apiKeys: apiKeys) // opensea or rarible
        //priceExplorer = Coingecko(coinSymbol: coinSymbol, isTestnet: isTestnet, apiKeys: apiKeys)
        priceExplorer = Coingate(coinSymbol: coinSymbol, isTestnet: isTestnet, apiKeys: apiKeys)
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
    
    public class override func contractStringToBytes(contractString: String) throws -> [UInt8] {
        var contractStr = contractString
        print("contractStr: \(contractStr)")
        let pattern = #"^(0x)?[0-9a-fA-F]{40}$"# //"^(0x)?[0-9a-fA-F]{40}$"
        if !contractStr.matches(pattern: pattern) {
            print("contractStr \(contractStr) does not match regex!")
            throw ContractParsingError.HexFormatError
        } else {
            print("contractStr \(contractStr) matches regex!")
        }
        print("\n\n\n")
        if contractStr.hasPrefix("0x"){
            contractStr = String(contractStr.dropFirst(2))
        }
        let contractBytes: [UInt8] = contractStr.hexToBytes
        if (contractBytes.count > 20) {
            throw ContractParsingError.TooLongError
        }
        return contractBytes
    }
    
    public override func tokenidBytesToString(tokenidBytes: [UInt8]) -> String {
        let biguint: BigUInt = BigUInt(Data(tokenidBytes))
        print("biguint: \(biguint.description)")
        return biguint.description
    }
    
    public class override func tokenidStringToBytes(tokenidString: String) throws -> [UInt8]{
        // tokenid is in decimal format
        print("tokenidString: \(tokenidString)")
        if tokenidString == "" {
            return [UInt8]()
        }
        
        let pattern = #"^\d+$"#
        if !tokenidString.matches(pattern: pattern) {
            throw ContractParsingError.DecimalFormatError
        }
        
        let biguint: BigUInt = BigUInt(stringLiteral: tokenidString)
        // todo: check 
        let tokenidBytes = [UInt8](biguint.serialize())
        print("tokenidBytes: \(tokenidBytes)")
        if tokenidBytes.count > 32 {
            throw ContractParsingError.TooLongError
        }
        return tokenidBytes
    }
    
}

