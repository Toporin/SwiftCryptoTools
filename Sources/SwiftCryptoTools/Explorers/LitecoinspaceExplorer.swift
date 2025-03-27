import Foundation

public class LitecoinspaceExplorer: BlockchainExplorer {
    
    // MARK: - Utilities
    
    public func getApiURL() -> String {
        if coinSymbol == "LTC" {
            return "https://litecoinspace.org/api/"
        }
        return "https://litecoinspace.org/testnet/api/"
    }
    
    public override func getAddressWebLink(addr: String) -> String {
        if coinSymbol == "LTC" {
            return "https://litecoinspace.org/address/" + addr
        }
        return "https://litecoinspace.org/testnet/address/" + addr
    }
    
    // MARK: - API Methods
    
    @available(iOS 15.0, *)
    public override func getCoinInfo(addr: String) async throws -> [String: String] {
        print("In LitecoinspaceExplorer getCoinInfo for: \(addr)")
        
        guard let url = URL(string: "\(getApiURL())address/\(addr)") else {
            throw DataFetcherError.invalidURL
        }
        
        print("urlString: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataFetcherError.networkError(NSError(domain: "", code: -1))
        }
        
        guard httpResponse.statusCode == 200 else {
            print("Failed to recover data from url \(url), response status \(httpResponse.statusCode)")
            throw DataFetcherError.invalidURL
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let chainStats = json["chain_stats"] as? [String: Any],
                  let fundedTxoSum = chainStats["funded_txo_sum"] as? Int,
                  let spentTxoSum = chainStats["spent_txo_sum"] as? Int else {
                throw DataFetcherError.decodingError(NSError(domain: "", code: -1))
            }
            
            var coinInfo: [String: String] = [:]
            
            // Compute balance
            print("DEBUG Litecoinspace funded_txo_sum \(fundedTxoSum)")
            print("DEBUG Litecoinspace spent_txo_sum \(spentTxoSum)")
            let divider: Double = pow(10, 8)
            let balance = Double(fundedTxoSum-spentTxoSum) / divider
            coinInfo["balance"] = String(balance)
            print("DEBUG Litecoinspace balance \(balance)")
            
            // Get exchange rate from third party
            if coin.isTestnet {
                coinInfo["exchangeRate"] = "0"
                coinInfo["currencyForExchangeRate"] = "USD"
            } else {
                do {
                    if let rate = try await coin.getExchangeRateWith(otherCoin: "USD"){
                        coinInfo["exchangeRate"] = String(rate)
                        coinInfo["currencyForExchangeRate"] = "USD"
                    }
                } catch {
                    coinInfo["error"] = error.localizedDescription
                }
            }
            
            // Basic info
            coinInfo["symbol"] = coinSymbol
            coinInfo["name"] = coin.displayName
            coinInfo["type"] = AssetType.coin.rawValue
            coinInfo["addressExplorerLink"] = getAddressWebLink(addr: addr)
            
            print("coin_info: \(coinInfo)")
            return coinInfo
            
        } catch {
            throw DataFetcherError.decodingError(error)
        }
    }
    
    @available(iOS 13.0.0, *)
    public override func getAssetList(addr: String) async throws -> [[String: String]] {
        // not supported
        return [[String:String]]()
    }
}
