import Foundation

public class UnsupportedCoin: BaseCoin {
    
    public override init(isTestnet: Bool, apiKeys: [String: String]){
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)

        if isTestnet {
            coinSymbol = "???"
            displayName = "Unsupported testnet coin"
            slip44 = 0x7fffffff
        } else {
            coinSymbol = "???"
            displayName = "Unsupported coin"
            slip44 = 0xffffffff
        }
    }
    
    //****************************************
    //*          ENCODING METHODS            *
    //****************************************
    
    public override func encodePrivkey(privkey: [UInt8]) -> String {
        return "(unsupported)"
    }
    
    public override func pubToAddress(pubkey: [UInt8]) throws -> String {
        return "(unsupported)"
    }
    
    //****************************************
    //*          EXPLORER METHODS            *
    //****************************************
    
    public func getBalance(addr: String) -> Double {
        return -1
    }
    
}

