//
//  PriceExplorer.swift
//  
//
//  Created by Satochip on 02/02/2023.
//

import Foundation

public class PriceExplorer: BaseExplorer {
    
    public var isTestnet: Bool
    
    init(coinSymbol: String, isTestnet: Bool, apiKeys: [String:String]){
        self.isTestnet = isTestnet
        super.init(coinSymbol: coinSymbol, apiKeys: apiKeys)
    }
    
    @available(iOS 15.0.0, *)
    public func getExchangeRateBetween(otherCoin: String) async throws -> Double {
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getExchangeRateBetween(coin: String, otherCoin: String) async throws -> Double {
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenExchangeRateBetween(contract: String, otherCoin: String) async throws -> Double {
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenExchangeRateBetween(coin: String, contract: String, otherCoin: String) async throws -> Double {
        preconditionFailure("This method must be overridden")
    }
    
    public func getPriceWeburl() -> String {
        preconditionFailure("This method must be overridden")
    }
    
    public func getPriceWeburl(coin: String) -> String {
        preconditionFailure("This method must be overridden")
    }
}
