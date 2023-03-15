import Foundation

public class EmptyCoin: BaseCoin {
    
    public override init(isTestnet: Bool, apiKeys: [String: String]){
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)

        if isTestnet {
            coinSymbol = ""
            displayName = "(Uninitialized)"
            slip44 = 0xdeadbeef
        } else {
            coinSymbol = ""
            displayName = "(Uninitialized))"
            slip44 = 0xdeadbeef
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

