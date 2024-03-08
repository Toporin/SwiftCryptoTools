//
//  File.swift
//  
//
//  Created by Lionel Delvaux on 06/03/2024.
//

import Foundation

public class Polygon: Ethereum {
        
        public override init(isTestnet: Bool, apiKeys: [String: String]){
            
            super.init(isTestnet: isTestnet, apiKeys: apiKeys)
            
            if (isTestnet){
                coinSymbol = "MATIC"
                displayName = "Matic Testnet"
                slip44 = 0x800003c6
            } else{
                coinSymbol = "MATIC"
                displayName = "Matic"
                slip44 = 0x800003c6
            }
            
            // TODO:
            //blockExplorer = Polygonscan(coinSymbol: coinSymbol, apiKeys: apiKeys)
            //priceExplorer = Coingecko(coinSymbol: coinSymbol, isTestnet: isTestnet, apiKeys: apiKeys)
        }
}
