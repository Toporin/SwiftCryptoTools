//
//  Coingate.swift
//
//
//  Created by Satochip on 02/02/2023.
//

import Foundation

public class Coingate: PriceExplorer {
    
    public struct CachedExchangeRate {
        var exchangeRate: Double
        var lastCheck: Date
    }
    
    public var cachedExchangeRateDict = [String:CachedExchangeRate]()
    
    public func getApiUrl() -> String {
        return "https://api.coingate.com/v2/rates/merchant/"
    }
    
    //deprecated
    @available(iOS 15.0.0, *)
    public override func getExchangeRateBetween(otherCoin: String) async throws -> Double {
        return try await getExchangeRateBetween(coin: self.coinSymbol, otherCoin: otherCoin)
    }
    
    @available(iOS 15.0.0, *)
    public override func getExchangeRateBetween(coin: String, otherCoin: String) async throws -> Double {
        print("Coingate getExchangeRateBetween: \(coin) and \(otherCoin)")
        
        if (coin == otherCoin){
            return 1
        }
        
        // check if cached
        if let exchangeRateData = cachedExchangeRateDict["\(coin):\(otherCoin)"]{
            let lastCheck = exchangeRateData.lastCheck
            let now = Date()
            let timeInterval = now.timeIntervalSince(lastCheck)
            print("timeInterval \(timeInterval)")
            // cache data is valid 300 sec
            if timeInterval < 300 {
                print("fetch cached data for \(coin):\(otherCoin)")
                return exchangeRateData.exchangeRate
            }
        }
        
        // TODO: coin must be listed
        // TODO: other_coin must be listed https://api.coingecko.com/api/v3/simple/supported_vs_currencies
        
        let urlString: String = self.getApiUrl() + coin +  "/" + otherCoin
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }
        
        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        print("Coingate getExchangeRateBetween data: \(data)")
        
        let resultString = String(data: data, encoding: .utf8)
        if let rate = Double(resultString ?? ""){
            print("Coingate getExchangeRateBetween rate: \(rate)")
            
            // cache data for future requests
            print("save cached data for \(coin):\(otherCoin)")
            cachedExchangeRateDict["\(coin):\(otherCoin)"]?.exchangeRate = rate
            cachedExchangeRateDict["\(coin):\(otherCoin)"]?.lastCheck = Date()
            
            return rate
        }
        
        throw DataFetcherError.missingData
    }
    
    public override func getPriceWeburl() -> String {
        return getPriceWeburl(coin: self.coinSymbol)
    }
    
    public override func getPriceWeburl(coin: String) -> String {
        // not supported
        let web_url = "https://coingate.com/en/exchange-rates"
        return web_url
    }
    
}

