//
//  PriceExplorer.swift
//  
//
//  Created by Satochip on 02/02/2023.
//

import Foundation

public class PriceExplorer: BaseExplorer {
    
    @available(iOS 15.0.0, *)
    public func getExchangeRateWith(otherCoin: String) async throws -> Double {
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getExchangeRateBetween(coin: String, otherCoin: String) async throws -> Double {
        preconditionFailure("This method must be overridden")
    }
    
    public func getPriceWeburl() -> String {
        preconditionFailure("This method must be overridden")
    }
    
    public func getPriceWeburl(coin: String) -> String {
        preconditionFailure("This method must be overridden")
    }
}
