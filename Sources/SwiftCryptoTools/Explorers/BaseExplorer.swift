import Foundation

enum DataFetcherError: Error {
    case invalidURL
    case missingData
}

public class BaseExplorer {
    
    public var coinSymbol: String
    public var apiKeys: [String:String]
    
    public init(coinSymbol: String, apiKeys: [String:String]){
        self.coinSymbol = coinSymbol
        self.apiKeys = apiKeys
    }
}
