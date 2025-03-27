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
            displayName = "Polygon Testnet"
            slip44 = 0x000003c6
        } else{
            coinSymbol = "POL"
            displayName = "Polygon"
            slip44 = 0x800003c6
        }
        
        supportToken = true
        supportNft = true
        explorers = [BlockscoutExplorer(coin: self, apiKeys: apiKeys)]
        priceExplorers = [Coingate(coin: self, apiKeys: apiKeys)]
    }
}
