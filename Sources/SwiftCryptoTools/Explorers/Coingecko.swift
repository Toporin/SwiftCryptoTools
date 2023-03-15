//
//  Coingecko.swift
//  
//
//  Created by Satochip on 02/02/2023.
//

import Foundation

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
    
    public func getApiUrl() -> String {
        return "https://api.coingecko.com/api/v3/"
    }
    
    @available(iOS 15.0.0, *)
    public override func getExchangeRateBetween(otherCoin: String) async throws -> Double {
        return try await getExchangeRateBetween(coin: self.coinSymbol, otherCoin: otherCoin)
    }
    
    @available(iOS 15.0.0, *)
    public override func getExchangeRateBetween(coin: String, otherCoin: String) async throws -> Double {
        print("Coingecko getExchangeRateBetween: \(coin) and \(otherCoin)")
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
                    print("rate: \(rate)")
                    return rate
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
