//
//  Polygon.swift
//
//
//  Created by Lionel Delvaux on 06/03/2024.
//

import Foundation
import CryptoSwift
import BigInt

public class Polygon: Ethereum {
        
    public override init(isTestnet: Bool, apiKeys: [String: String]){
        
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)
        
        if (isTestnet){
            coinSymbol = "MUMBAI"
            displayName = "Matic Testnet"
            slip44 = 0x800003c6
        } else{
            coinSymbol = "MATIC"
            displayName = "Matic"
            slip44 = 0x800003c6
        }
        
        supportToken = true
        supportNft = true
        blockExplorer = Covalent(coinSymbol: coinSymbol, apiKeys: apiKeys)
        nftExplorer = CovalentNFT(coinSymbol: self.coinSymbol, apiKeys: apiKeys)
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
