import Foundation

public class Litecoin: Bitcoin {

    public override init(isTestnet: Bool, apiKeys: [String: String]){
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)
        
        if self.isTestnet {
            coinSymbol = "LTCTEST"
            displayName = "Litecoin Testnet"
            slip44 = 0x00000002
            magicbyte = 111
            scriptMagicbyte = 58
            segwitHrp = "tltc"
        } else {
            coinSymbol = "LTC"
            displayName = "Litecoin"
            slip44 = 0x80000002
            magicbyte = 48
            scriptMagicbyte = 50
            segwitHrp = "ltc"
            wifPrefix = 0xb0
        }
        
        explorers = [LitecoinspaceExplorer(coin: self, apiKeys: apiKeys)]
        priceExplorers = [Coingate(coin: self, apiKeys: apiKeys)]
    }
}

