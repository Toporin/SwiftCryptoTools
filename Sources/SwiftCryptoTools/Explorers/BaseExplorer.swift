import Foundation

enum DataFetcherError: Error {
    case invalidURL
    case missingData
    case unsupportedCoin(coin: String)
    case networkError(Error)
    case decodingError(Error)
}

public class BaseExplorer {
    
    public var coin: BaseCoin
    public var coinSymbol: String
    public var apiKeys: [String:String]
    
    public init(coin: BaseCoin, apiKeys: [String:String]){
        self.coin = coin
        self.coinSymbol = coin.coinSymbol
        self.apiKeys = apiKeys
    }
}
