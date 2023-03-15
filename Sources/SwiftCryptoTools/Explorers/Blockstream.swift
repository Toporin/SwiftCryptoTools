import Foundation

public class Blockstream: BlockExplorer {
    
    struct ChainStats: Codable {
        let fundedTxoSum: Int64
        let spentTxoSum: Int64
        enum CodingKeys: String, CodingKey {
            case fundedTxoSum = "funded_txo_sum", spentTxoSum = "spent_txo_sum"
        }
    }

    struct JsonResponseBalance: Codable {
        let address: String
        let chainStats: ChainStats
        enum CodingKeys: String, CodingKey {
            case address, chainStats = "chain_stats"
        }
    }
    
    public func getUrl() -> String {
        if self.coinSymbol == "BTC" {
            return "https://blockstream.info/api/"
        } else {
            return "https://blockstream.info/testnet/api/"
        }
    }
    
    public override func getAddressWebLink(addr: String) -> String {
        if self.coinSymbol == "BTC" {
            return "https://blockstream.info/address/"+addr
        } else {
            return "https://blockstream.info/testnet/address/"+addr
        }
    }
    
    /// Make network request using async `URLSession` API
    @available(iOS 15.0, *)
    public override func getBalance(addr: String) async throws -> Double {
        print("In Blockstream getBalance for: \(addr)")
        
        // https://blockstream.info/api/address/ + addr
        let urlString: String = self.getUrl() + "address/" + addr
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
        
        let fundedTxoSum: Int64 = result.chainStats.fundedTxoSum
        let spentTxoSum: Int64 = result.chainStats.spentTxoSum
        let balance: Double = Double(fundedTxoSum-spentTxoSum)/Double(100_000_000)
        return balance
    }

}
