import Foundation

public class NftExplorer: BaseExplorer {
    
    public override init(coinSymbol: String, apiKeys: [String:String]){
        super.init(coinSymbol: coinSymbol, apiKeys: apiKeys)
    }
    
    public func getNftOwnerWebLink(addr: String) -> String {
        preconditionFailure("This method must be overridden")
    }
    
    public func getNftWebLink(contract: String, tokenid: String) -> String {
        preconditionFailure("This method must be overridden")
    }
    
    //debug
    @available(iOS 15.0.0, *)
    public func getNftList(addr: String, contract: String) async throws -> [[String:String]] {
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getNftInfo(contract: String, tokenid: String) async throws -> [String:String] {
        preconditionFailure("This method must be overridden")
    }
}
