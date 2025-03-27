import Foundation

public class TokenscanExplorer: BlockchainExplorer {

    public override init(coin: BaseCoin, apiKeys: [String: String]) {
        super.init(coin: coin, apiKeys: apiKeys)
    }
    
    // MARK: - Utilities
    
    private func getURL() -> String {
        let urls: [String: String] = [
            "XCP": "https://tokenscan.io/",
            "XCPTEST": "https://testnet.tokenscan.io/",
            "XDP": "https://dogeparty.tokenscan.io/",
            "XDPTEST": "https://dogeparty-testnet.tokenscan.io/"
        ]
        return urls[coinSymbol] ?? "https://notfound.org/"
    }
    
    public override func getAddressWebLink(addr: String) -> String {
        return "\(getURL())address/\(addr)"
    }
    
    public func getTokenWebURL(contract: String) -> String {
        return "\(getURL())asset/\(contract)"
    }
    
    // MARK: - API Methods
    
    @available(iOS 15.0, *)
    public override func getCoinInfo(addr: String) async throws -> [String: String] {
        print("In TokenscanExplorer getCoinInfo for: \(addr)")
        
        guard let url = URL(string: "\(getURL())api/address/\(addr)") else {
            throw DataFetcherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataFetcherError.networkError(NSError(domain: "", code: -1))
        }
        
        guard httpResponse.statusCode == 200 else {
            throw DataFetcherError.invalidURL
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw DataFetcherError.decodingError(NSError(domain: "", code: -1))
            }
            
            var coinInfo: [String: String] = [:]
            
            // Parse balance
            if let balance = json["xcp_balance"] as? String {
                coinInfo["balance"] = balance
            }
            
            // Parse exchange rate
            if let estimatedValue = json["estimated_value"] as? [String: Any],
               let usdValue = estimatedValue["usd"] as? Double,
               let xcpValue = estimatedValue["xcp"] as? Double 
            {
                print("DEBUG TokenscanExplorer rates: \(estimatedValue)")
                if xcpValue != 0 {
                    coinInfo["exchangeRate"] = String(usdValue / xcpValue)
                    coinInfo["currencyForExchangeRate"] = "USD"
                    print("DEBUG TokenscanExplorer exchangeRate: \(String(describing: coinInfo["exchangeRate"])) \(String(describing: coinInfo["currencyForExchangeRate"]))")
                }
            }
            
            // Add additional info
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
    
    @available(iOS 15.0, *)
    public override func getAssetList(addr: String) async throws -> [[String: String]] {
        print("in TokenscanExplorer get_asset_list - addr: \(addr)")
        
        guard let url = URL(string: "\(getURL())api/balances/\(addr)") else {
            throw DataFetcherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataFetcherError.networkError(NSError(domain: "", code: -1))
        }
        
        guard httpResponse.statusCode == 200 else {
            throw DataFetcherError.invalidURL
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let items = json["data"] as? [[String: Any]] else {
                throw DataFetcherError.decodingError(NSError(domain: "", code: -1))
            }
            
            print("asset_list size: \(items.count)")
            
            var assetList: [[String: String]] = []
            
            for item in items {
                print("DEBUG asset: \(item)")
                var asset: [String: String] = [:]
                
                // Basic asset info
                let name = (item["asset"] as? String) ?? ""
                if (name == "XCP"){
                    // skip XCP native coin
                    continue
                }
                asset["name"] = name
                asset["contract"] = name
                asset["symbol"] = (item["symbol"] as? String) ?? ""
                asset["description"] = (item["description"] as? String) ?? ""
                asset["balance"] = (item["quantity"] as? String) ?? ""
                
                // Exchange rate
                if let estimatedValue = item["estimated_value"] as? [String: Any],
                   let usdValue = estimatedValue["usd"] as? String {
                    asset["exchangeRate"] = usdValue
                    asset["currencyForExchangeRate"] = "USD"
                }
                
                // NFT info from description
                if var description = item["description"] as? String {
                    if description.hasPrefix("*") {
                        description = String(description.dropFirst())
                    }
                    
                    if description.hasPrefix("imgur/") {
                        let blob = String(description.dropFirst("imgur/".count))
                        let blobSplit = blob.split(separator: ";")
                        if let part = blobSplit.first {
                            let imlink = "https://i.imgur.com/\(part)"
                            asset["nftImageUrl"] = imlink
                        }
                    } else if description.hasPrefix("https://") || description.hasPrefix("http://") {
                        if description.hasSuffix(".png") ||
                            description.hasSuffix(".jpg") ||
                            description.hasSuffix(".jpeg") ||
                            description.hasSuffix(".gif") {
                            asset["nftImageUrl"] = description
                        } else if description.hasSuffix(".json") {
                            let jsonLink = description
                            print("DEBUG tokenscan.io json_link: \(jsonLink)")
                            
                            if let jsonUrl = URL(string: jsonLink) {
                                do {
                                    let (jsonData, _) = try await URLSession.shared.data(from: jsonUrl)
                                    if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                                        if let imageLarge = jsonResponse["image_large"] as? String {
                                            asset["nftImageUrl"] = imageLarge
                                        } else if let image = jsonResponse["image"] as? String {
                                            asset["nftImageUrl"] = image
                                        }
                                    }
                                } catch {
                                    print("EXCEPTION tokenscan.io get_nft_info json_link exception: \(error)")
                                }
                            }
                        } else {
                            asset["nftDescription"] = (asset["nftDescription"] ?? "") + description
                        }
                    }
                }
                
                // Set type and explorer URLs
                if asset["nftImageUrl"]?.isEmpty == false {
                    asset["type"] = AssetType.nft.rawValue
                    asset["nftExplorerLink"] = getTokenWebURL(contract: asset["name"] ?? "")
                } else {
                    asset["type"] = AssetType.token.rawValue
                    asset["tokenExplorerLink"] = getTokenWebURL(contract: asset["name"] ?? "")
                }
                
                asset["addressExplorerLink"] = getAddressWebLink(addr: addr)
                
                assetList.append(asset)
            }
            
            return assetList
            
        } catch {
            throw DataFetcherError.decodingError(error)
        }
    }
}
