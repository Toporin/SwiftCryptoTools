import Foundation

public class Sochain: BlockExplorer {
    
    struct Data: Codable {
        let network: String
        let address: String
        let confirmed_balance: String
        let unconfirmed_balance: String
        enum CodingKeys: String, CodingKey {
            case network, address, confirmed_balance, unconfirmed_balance
        }
    }

    struct JsonResponseBalance: Codable {
        let status: String
        let data: Data
        enum CodingKeys: String, CodingKey {
            case status, data
        }
    }
    
    public func getUrl() -> String {
        return "https://chain.so/api/v2/"
    }
    
    public override func getAddressWebLink(addr: String) -> String {
        return "https://chain.so/address/" + self.coinSymbol + "/" + addr
    }
    
    /// Make network request using async `URLSession` API
    @available(iOS 15.0, *)
    public override func getBalance(addr: String) async throws -> Double {
        
        let urlString: String = self.getUrl() + "get_address_balance/" + self.coinSymbol + "/" + addr
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseBalance.self, from: data)
        print("result: \(result)")
        
        guard let balance: Double = Double(result.data.confirmed_balance) else {
            throw DataFetcherError.missingData
        }
        return balance
    }
}

