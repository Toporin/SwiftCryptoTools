import Foundation

public class BlockExplorer: BaseExplorer {
    
    public override init(coinSymbol: String, apiKeys: [String:String]){
        super.init(coinSymbol: coinSymbol, apiKeys: apiKeys)
    }
    
    public func getAddressWebLink(addr: String) -> String { // todo: use address instead of addr
        preconditionFailure("This method must be overridden")
    }
    
    public func getTokenWebLink(contract: String) -> String {
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getBalance(addr: String) async throws -> Double {
        preconditionFailure("This method must be overridden")
    }
    
    // returns detailed list of data about each asset held in a given address
    @available(iOS 15.0.0, *)
    public func getAssetList(addr: String) async throws -> [String:[[String:String]]] {
        preconditionFailure("This method must be overridden")
    }
    
    // returns basic list of data about each asset held in a given address
    @available(iOS 15.0.0, *)
    public func getSimpleAssetList(addr: String) async throws -> [[String:String]] {
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenBalance(addr: String, contract: String) async throws -> Double {
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenInfo(contract: String) async throws -> [String:String] {
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getTxInfo(txHash: String, index: Int) async throws -> (script: String, value: UInt64) {
        preconditionFailure("This method must be overridden")
    }
    
}
 
