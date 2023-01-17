import Foundation

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
            wifPrefix = 0xb0
        }
        
        supportNft = true
        supportToken = true
        blockExplorer = XchainBlockExplorer(coinSymbol: self.coinSymbol, apiKeys: apiKeys)
        nftExplorer = XchainNftExplorer(coinSymbol: self.coinSymbol, apiKeys: apiKeys)
    }

    public override func contractBytesToString(contractBytes: [UInt8]) -> String {
        if let contractString = String(bytes: contractBytes, encoding: .utf8) {
            print("contractString: \(contractString)")
            return contractString
        } else {
            print("not a valid UTF-8 sequence")
            return ""
        }
    }
    
    public override func tokenidBytesToString(tokenidBytes: [UInt8]) -> String {
        return "" // Counterparty does not use tokenid
    }
    
    
}
