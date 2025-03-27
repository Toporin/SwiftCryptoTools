import Foundation

enum AssetType: String {
    case coin
    case token
    case nft
}

public class BlockchainExplorer: BaseExplorer {
    
    public override init(coin: BaseCoin, apiKeys: [String:String]){
        super.init(coin: coin, apiKeys: apiKeys)
    }
    
    public func getAddressWebLink(addr: String) -> String { // todo: use address instead of addr
        preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getCoinInfo(addr: String) async throws -> [String:String] {
        preconditionFailure("This method must be overridden")
    }
    
    // returns detailed list of data about each asset held in a given address
    @available(iOS 15.0.0, *)
    public func getAssetList(addr: String) async throws -> [[String:String]] {
        preconditionFailure("This method must be overridden")
    }
    
}
 
