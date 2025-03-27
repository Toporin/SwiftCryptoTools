import Foundation

public class FullstackExplorer: BlockchainExplorer {
    
    // MARK: - Utilities
    
    public func getApiURL() -> String {
        if coinSymbol == "BCH" {
            return "https://api.fullstack.cash/v5/"
        }
        return "https://tapi.fullstack.cash/v5/"
    }
    
    public override func getAddressWebLink(addr: String) -> String {
        // address in cashaddress format such as bchtest:qps822p04zpg676v6krnwhjhtqx44klcvqjrg353rc
        if coinSymbol == "BCH" {
            return "https://www.blockchain.com/bch/address/\(addr)"
        }
        return "https://www.blockchain.com/bch-testnet/address/\(addr)"
    }
    
    // MARK: - API Methods
    
    @available(iOS 15.0, *)
    public override func getCoinInfo(addr: String) async throws -> [String: String] {
        print("In FullstackExplorer getCoinInfo for: \(addr)")
        
        guard let url = URL(string: "\(getApiURL())electrumx/balance/\(addr)") else {
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
                  let isSuccess = json["success"] as? Bool else {
                throw DataFetcherError.decodingError(NSError(domain: "", code: -1))
            }
            
            var coinInfo: [String: String] = [:]
            
            if isSuccess {
                guard let balanceData = json["balance"] as? [String: Any],
                      let confirmedBalance = balanceData["confirmed"] as? Int else {
                    throw DataFetcherError.decodingError(NSError(domain: "", code: -1))
                }
                print("In FullstackExplorer balanceData:\(balanceData) - confirmedBalance:\(confirmedBalance)")
                
                // Convert satoshi to BCH by moving decimal point 8 places left
                let divider: Double = pow(10, 8)
                let balance = Double(confirmedBalance) / divider
                coinInfo["balance"] = String(balance)
            } else {
                throw DataFetcherError.decodingError(NSError(domain: "", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Failed to recover balance from FullstackExplorer"
                ]))
            }
            
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
