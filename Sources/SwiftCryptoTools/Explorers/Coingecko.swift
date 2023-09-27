//
//  Coingecko.swift
//  
//
//  Created by Satochip on 02/02/2023.
//

import Foundation

public struct CachedExchangeRate {
    var exchangeRate: Double
    var lastCheck: Date
}

public class Coingecko: PriceExplorer {
    
    static public var symbolToId: [String : String] = [
        "BTC" : "bitcoin",
        "LTC" : "litecoin",
        "BCH" : "bitcoin-cash",
        "ETH" : "ethereum",
        "ETC" : "ethereum-classic",
        "XCP" : "counterparty"
    ]
    static public var nameToId: [String : String] = [
        "BTC" : "btc",
        "ETH" : "eth",
        "EUR" : "eur",
        "USD" : "usd",
    ]
    
    public var cachedExchangeRateDict = [String:CachedExchangeRate]()
    
    public func getApiUrl() -> String {
        return "https://api.coingecko.com/api/v3/"
    }
    
    //deprecated
    @available(iOS 15.0.0, *)
    public override func getExchangeRateBetween(otherCoin: String) async throws -> Double {
        return try await getExchangeRateBetween(coin: self.coinSymbol, otherCoin: otherCoin)
    }
    
    @available(iOS 15.0.0, *)
    public override func getExchangeRateBetween(coin: String, otherCoin: String) async throws -> Double {
        print("Coingecko getExchangeRateBetween: \(coin) and \(otherCoin)")
        
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
        
        // TODO: coin must be listed in https://api.coingecko.com/api/v3/coins/list
        // TODO: other_coin must be listed in https://api.coingecko.com/api/v3/simple/supported_vs_currencies
        var needsInversion = false
        var coinId = ""
        var otherCoinId = ""
        if let coinIdTmp = Coingecko.symbolToId[coin],
           let otherCoinIdTmp = Coingecko.nameToId[otherCoin] {
            coinId = coinIdTmp
            otherCoinId = otherCoinIdTmp
        } else {
            // if one pair is not available, it might be available in the other direction
            // then we can take the inverse exchange rate
            if let coinIdTmp = Coingecko.symbolToId[otherCoin],
               let otherCoinIdTmp = Coingecko.nameToId[coin] {
                needsInversion = true
                coinId = coinIdTmp
                otherCoinId = otherCoinIdTmp
            } else {
                print("Coingecko getExchangeRateBetween Error: no exchange rate for pair \(coin):\(otherCoin)")
                throw DataFetcherError.unsupportedCoin(coin: coin)
            }
        }
        
        let urlString: String = self.getApiUrl() + "simple/price?ids=" + coinId +  "&vs_currencies=" + otherCoinId
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }
        
        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // try to read out a string array
            if let dic = json[coinId] as? [String:Double] {
                print("dic: \(dic)")
                if let rate = dic[otherCoinId] {
                    print("Coingecko getExchangeRateBetween rate: \(rate)")
                    
                    if needsInversion {
                        let inverseRate = 1.0/rate
                        
                        // cache data for future requests
                        print("save cached data for \(coin):\(otherCoin)")
                        cachedExchangeRateDict["\(coin):\(otherCoin)"]?.exchangeRate = inverseRate
                        cachedExchangeRateDict["\(coin):\(otherCoin)"]?.lastCheck = Date()
                        
                        return inverseRate
                        
                    } else {
                        
                        // cache data for future requests
                        print("save cached data for \(coin):\(otherCoin)")
                        cachedExchangeRateDict["\(coin):\(otherCoin)"]?.exchangeRate = rate
                        cachedExchangeRateDict["\(coin):\(otherCoin)"]?.lastCheck = Date()
                        
                        return rate
                    }
                }
            }
        }
        throw DataFetcherError.missingData
    }
    
    @available(iOS 15.0.0, *)
    public override func getTokenExchangeRateBetween(contract: String, otherCoin: String) async throws -> Double {
        return try await  getTokenExchangeRateBetween(coin: self.coinSymbol, contract: contract, otherCoin: otherCoin)
    }
    
    @available(iOS 15.0.0, *)
    public override func getTokenExchangeRateBetween(coin: String, contract: String, otherCoin: String) async throws -> Double {
        
        if (self.isTestnet){
            return 0
        }
        
        // TODO: coin must be listed in https://api.coingecko.com/api/v3//coins/list
        // TODO: other_coin must be listed in https://api.coingecko.com/api/v3/simple/supported_vs_currencies
        guard let coinId = Coingecko.symbolToId[coin] else {
            throw DataFetcherError.unsupportedCoin(coin: coin)
        }
        guard let otherCoinId = Coingecko.nameToId[otherCoin] else {
            throw DataFetcherError.unsupportedCoin(coin: otherCoin)
        }
        let urlString: String = self.getApiUrl() + "simple/token_price/" + coinId + "?contract_addresses="+contract + "&vs_currencies=" + otherCoinId
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }
        
        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // try to read out a string array
            if let dic = json[contract] as? [String:Double] {
                print("dic: \(dic)")
                if let rate = dic[otherCoinId] {
                    print("rate: \(rate)")
                    return rate
                }
            }
        }
        throw DataFetcherError.missingData
    }
    
    public override func getPriceWeburl() -> String {
        return getPriceWeburl(coin: self.coinSymbol)
    }
    
    public override func getPriceWeburl(coin: String) -> String {
         let web_url = "https://www.coingecko.com/en/coins/" + coin
         return web_url
    }
    
}
