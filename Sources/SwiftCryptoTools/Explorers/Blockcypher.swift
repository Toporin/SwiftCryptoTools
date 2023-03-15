import Foundation

public class Blockcypher: BlockExplorer {
    
    // doc: https://www.blockcypher.com/dev/bitcoin/#introduction
    
    struct JsonResponseBalance: Codable {
        let address: String
        let balance: Int64
        enum CodingKeys: String, CodingKey {
            case address, balance
        }
    }
    
    public func getUrl() -> String {
        if self.coinSymbol == "LTC" {
            return "https://api.blockcypher.com/v1/ltc/main/"
        } else if self.coinSymbol == "DOGE" {
            return "https://api.blockcypher.com/v1/doge/main/"
        } else {
            return ""
        }
    }
    
    public override func getAddressWebLink(addr: String) -> String {
        if self.coinSymbol == "LTC" {
            return "https://live.blockcypher.com/ltc/address/"+addr
        } else if self.coinSymbol == "DOGE" {
            return "https://live.blockcypher.com/doge/address/"+addr
        } else {
            return ""
        }
    }
    
    /// Make network request using async `URLSession` API
    @available(iOS 15.0, *)
    public override func getBalance(addr: String) async throws -> Double {
        print("In Blockcypher getBalance for: \(addr)")
        
        // https://api.blockcypher.com/v1/btc/main/addrs/1DEP8i3QJCsomS4BSMY2RpU1upv62aGvhD/balance
        let urlString: String = self.getUrl() + "addrs/" + addr + "/balance"
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        print("data: \(data)")
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseBalance.self, from: data)
        print("result: \(result)")
        
//        let fundedTxoSum: Int64 = result.chainStats.fundedTxoSum
//        let spentTxoSum: Int64 = result.chainStats.spentTxoSum
        let balanceInt: Int64 = result.balance
        let balance: Double = Double(balanceInt)/Double(100_000_000)
        return balance
    }

}

