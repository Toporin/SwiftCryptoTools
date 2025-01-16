import Foundation
import BigInt

public class Counterparty: Bitcoin {
    
    public override init(isTestnet: Bool, apiKeys: [String: String]){
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)
        
        supportSegwit = false
        
        if self.isTestnet {
            coinSymbol = "XCPTEST"
            displayName = "Counterparty Testnet"
            slip44 = 0x00000009
        } else {
            coinSymbol = "XCP"
            displayName = "Counterparty"
            slip44 = 0x80000009
            //wifPrefix = 0xb0 // use same as bitcoin
        }
        
        supportNft = true
        supportToken = true
        explorers = [TokenscanExplorer(coin: self, apiKeys: apiKeys)]
        priceExplorers = [Coingate(coin: self, apiKeys: apiKeys), Coingecko(coin: self, apiKeys: apiKeys)]
    }

}
