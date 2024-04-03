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
            slip44 = 0x000003c6
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
}
