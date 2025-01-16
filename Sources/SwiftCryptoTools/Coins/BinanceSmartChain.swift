import Foundation
import CryptoSwift
import BigInt

public class BinanceSmartChain: Ethereum {
    
   
    public override init(isTestnet: Bool, apiKeys: [String: String]){
    
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)
        
        useCompressedAddr = false
        
        // todo: switch to goerli
        if (isTestnet){
            coinSymbol = "BNBTEST"
            displayName = "BSC Testnet"
            slip44 = 0x0000232e
        } else{
            coinSymbol = "BNB"
            displayName = "Binance Smart Chain"
            slip44 = 0x8000232e
        }
        
        explorers = [BlockscoutExplorer(coin: self, apiKeys: apiKeys)]
        priceExplorers = [Coingate(coin: self, apiKeys: apiKeys)]
        
        supportToken = true
        supportNft = false
//        nftExplorer = nil // currently not supported
//        blockExplorer = Ethplorer(coinSymbol: coinSymbol, apiKeys: apiKeys)
//        priceExplorer = Coingate(coin: self, apiKeys: apiKeys)
    }
    
}

