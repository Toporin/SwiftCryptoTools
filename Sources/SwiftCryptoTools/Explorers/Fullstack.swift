import Foundation

public class Fullstack: BlockExplorer {
    
    struct Balance: Codable {
        let confirmed: Int64
        let unconfirmed: Int64
        enum CodingKeys: String, CodingKey {
            case confirmed, unconfirmed
        }
    }

    struct JsonResponseBalance: Codable {
        let success: Bool
        let balance: Balance
        enum CodingKeys: String, CodingKey {
            case success, balance
        }
    }
    
    public func getUrl() -> String {
        if self.coinSymbol == "BCH" {
            return "https://api.fullstack.cash/v5"
        } else {
            return "https://tapi.fullstack.cash/v5"
        }
    }
    
    public override func getAddressWebLink(addr: String) -> String {
        if self.coinSymbol == "BCH" {
            return "https://www.blockchain.com/bch/address/" + addr
        } else {
            return "https://www.blockchain.com/bch-testnet/address/" + addr
        }
    }
    
    /// Make network request using async `URLSession` API
    @available(iOS 15.0, *)
    public override func getBalance(addr: String) async throws -> Double {
        print("in Fullstack getBalance - addr: \(addr)")
        // https://api.fullstack.cash/v5/electrumx/balance/bitcoincash:qzrxy8wdjvd2qkjswuefc6exrjhy55mfpc3m0ap8t4
        // returns {"success":true,"balance":{"confirmed":0,"unconfirmed":0}}
        let urlString: String = self.getUrl() + "/electrumx/balance/" + addr
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseBalance.self, from: data)
        print("result: \(result)")
        
        let balance: Double = Double(result.balance.confirmed)/Double(100_000_000)
        return balance
    }
    
    @available(iOS 15.0.0, *)
    public override func getSimpleAssetList(addr: String) async throws -> [[String:String]] {
        // token not (yet) supported on BCH by satodime
        return [[String:String]]()
    }
}
