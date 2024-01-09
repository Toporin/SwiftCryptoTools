import Foundation

public class UnsupportedBitcoinFork: Bitcoin {
    
    public override init(isTestnet: Bool, apiKeys: [String: String]){
        
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)
        
        supportSegwit = true
        if self.isTestnet {
            coinSymbol = "???Test"
            displayName = "Unsupported Bitcoin Fork (testnet)"
            slip44 = 0x7fffffff
        } else {
            coinSymbol = "???"
            displayName = "Unsupported Bitcoin Fork"
            slip44 = 0xffffffff
        }
    }
    
}

