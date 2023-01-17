import Foundation

public class BlockExplorer: BaseExplorer {
    
    public override init(coinSymbol: String, apiKeys: [String:String]){
        super.init(coinSymbol: coinSymbol, apiKeys: apiKeys)
    }
    
    public func getAddressWeburl(addr: String) -> String {
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getBalance(addr: String) async throws -> Double {
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
    
}
 
