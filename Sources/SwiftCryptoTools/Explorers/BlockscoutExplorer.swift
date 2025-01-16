import Foundation


public class BlockscoutExplorer: BlockchainExplorer {
    // Docs: https://polygon.blockscout.com/api-docs
    
    // MARK: - Utilities
    
    private func getWebURL() -> String {
        let urls: [String: String] = [
            "ETH": "https://eth.blockscout.com/",
            "ETHTEST": "https://eth-sepolia.blockscout.com/",
            "ETC": "https://etc.blockscout.com/",
            "ETCTEST": "https://etc-mordor.blockscout.com/",
            "BASE": "https://base.blockscout.com/",
            "BASETEST": "https://base-sepolia.blockscout.com/",
            "POL": "https://polygon.blockscout.com/"
        ]
        return urls[coinSymbol] ?? "https://notfound.org/"
    }
    
    public func getAPIURL() -> String {
        return getWebURL() + "api/v2/"
    }
    
    public override func getAddressWebLink(addr: String) -> String {
        return "\(getWebURL())address/\(addr)"
    }
    
    public func getTokenWebURL(contract: String) -> String {
        return "\(getWebURL())token/\(contract)"
    }
    
    public func getNFTWebURL(contract: String, tokenid: String) -> String {
        return "\(getWebURL())token/\(contract)/instance/\(tokenid)"
    }
    
    // MARK: - API
        
    @available(iOS 15.0, *)
    public override func getCoinInfo(addr: String) async throws -> [String: String] {
        print("In BlockscoutExplorer getCoinInfo for: \(addr)")
        
        guard let url = URL(string: "\(getAPIURL())addresses/\(addr)") else {
            throw DataFetcherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataFetcherError.networkError(NSError(domain: "", code: -1))
        }
        
        if httpResponse.statusCode == 404 {
            // not found in blockchain
            return [
                "balance": "0",
                "symbol": coinSymbol,
                "name": coin.displayName,
                "type": AssetType.coin.rawValue,
                "addressExplorerLink": getAddressWebLink(addr: addr)
            ]
        }
        
        guard httpResponse.statusCode == 200 else {
            throw DataFetcherError.invalidURL
        }
        
        return try parseCoinInfoJSON(data: data, addr: addr)
    }
    
    @available(iOS 15.0, *)
    public override func getAssetList(addr: String) async throws -> [[String: String]] {
        print("In BlockscoutExplorer getAssetList for: \(addr)")
        
        var assetList = [[String:String]]()
        var assetListPartial = [[String:String]]()
             
        // for pagination: https://docs.blockscout.com/devs/apis/rest
        var next_page_params = ""
        repeat {
            
            guard var url = URL(string: "\(getAPIURL())addresses/\(addr)/tokens\(next_page_params)") else {
                throw DataFetcherError.invalidURL
            }
            print("In BlockscoutExplorer getAssetList url: \(url)")
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DataFetcherError.networkError(NSError(domain: "", code: -1))
            }
            
            if httpResponse.statusCode == 404 {
                return []
            }
            
            guard httpResponse.statusCode == 200 else {
                throw DataFetcherError.invalidURL
            }
            
            (assetListPartial, next_page_params) = try parseAssetListJSON(data: data, addr: addr)
            assetList += assetListPartial
            //print("next_page_params: \(next_page_params)")
            
        } while (next_page_params != "")
        
        return assetList
    }
    
    // MARK: - Parsers
    
    private func parseCoinInfoJSON(data: Data, addr: String) throws -> [String: String] {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw DataFetcherError.decodingError(NSError(domain: "", code: -1))
            }
            
            var result: [String: String] = [:]
            
            // Convert wei to ether
            if let coinBalanceWei = json["coin_balance"] as? String {
                // Dividing by 10^18 by moving decimal point 18 places left
                let decimalPoint = coinBalanceWei.count - 18
                if decimalPoint > 0 {
                    let idx = coinBalanceWei.index(coinBalanceWei.startIndex, offsetBy: decimalPoint)
                    result["balance"] = String(coinBalanceWei[..<idx]) + "." + String(coinBalanceWei[idx...])
                } else {
                    result["balance"] = "0." + String(repeating: "0", count: -decimalPoint) + coinBalanceWei
                }
            } else {
                result["balance"] = "0"
            }
            
            result["symbol"] = coinSymbol
            result["name"] = coin.displayName
            result["type"] = AssetType.coin.rawValue
            result["addressExplorerLink"] = getAddressWebLink(addr: addr)
            
            if let exchangeRate = json["exchange_rate"] as? String {
                result["exchangeRate"] = exchangeRate
                result["currencyForExchangeRate"] = "USD"
            }
            
            if let ensDomain = json["ens_domain_name"] as? String {
                result["ens_domain"] = ensDomain
            }
            
            return result
            
        } catch {
            throw DataFetcherError.decodingError(error)
        }
    }
    
    private func parseAssetListJSON(data: Data, addr: String) throws -> ([[String: String]], String) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let items = json["items"] as? [[String: Any]] else {
                throw DataFetcherError.decodingError(NSError(domain: "", code: -1))
            }
            
            let assetList = items.compactMap { item -> [String: String]? in
                guard let token = item["token"] as? [String: Any],
                      let address = token["address"] as? String,
                      let type = token["type"] as? String else {
                    return nil
                }
                
                var asset: [String: String] = [:]
                
                if let name = token["name"] as? String {
                    asset["name"] = name
                }
                asset["contract"] = address
                
                if let icon_url = token["icon_url"] as? String {
                    asset["tokenIconUrl"] = icon_url
                }
                
                // Handle asset type
                switch type {
                case "ERC-20":
                    asset["type"] = AssetType.token.rawValue
                case "ERC-721", "ERC-1155":
                    asset["type"] = AssetType.nft.rawValue
                default:
                    return nil
                }
                
                // Handle balance
                if let value = item["value"] as? String {
                    
                    let decimals = (token["decimals"] as? String) ?? "0"
                    let decimalCount = Int(decimals) ?? 0
                    
                    let decimalPoint = value.count - decimalCount
                    if decimalPoint > 0 {
                        let idx = value.index(value.startIndex, offsetBy: decimalPoint)
                        asset["balance"] = String(value[..<idx]) + "." + String(value[idx...])
                    } else {
                        asset["balance"] = "0." + String(repeating: "0", count: -decimalPoint) + value
                    }
                }
                
                // Handle exchange rate
                if let exchangeRate = token["exchange_rate"] as? String {
                    asset["exchangeRate"] = exchangeRate
                    asset["currencyForExchangeRate"] = "USD"
                }
                
                // Handle NFT specific data
                if let tokenInstance = item["token_instance"] as? [String: Any] {
                    if let tokenid = tokenInstance["id"] as? String {
                        asset["tokenid"] = tokenid
                        asset["nftExplorerLink"] = getNFTWebURL(contract: address, tokenid: tokenid)
                    }
                    if let imageUrl = tokenInstance["image_url"] as? String {
                        asset["nftImageUrl"] = imageUrl
                    }
                }
                
                // Add explorer URLs
                asset["tokenExplorerLink"] = getTokenWebURL(contract: address)
                asset["addressExplorerLink"] = getAddressWebLink(addr: addr)
                
                return asset
            }
            
            // handle pagination
            var next_page_params = ""
            if let paginationDic = json["next_page_params"] as? [String: Any] {
                //print("paginationDic: \(paginationDic)")
                next_page_params = serializeQueryParameters(paginationDic)
                //print("serialized to next_page_params: \(next_page_params)")
            }
            
            return (assetList, next_page_params)
            
        } catch {
            throw DataFetcherError.decodingError(error)
        }
    }
    
    private func serializeQueryParameters(_ params: [String: Any?]?) -> String {
        // serialize the pagination parameters into a string
        
        guard let params = params else {
            return ""
        }
        
        let queryItems = params.compactMap { key, value -> String? in
            
            let stringValue: String
            if value is NSNull {
                stringValue = "null"
            } else {
                stringValue = "\(value ?? "")"
            }
            //print("stringValue: \(stringValue)")
    
            // URL encode the value
            guard let encoded = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
            
            return "\(key)=\(encoded)"
        }
        
        let queryString = queryItems.joined(separator: "&")
        
        if queryString.isEmpty {
            return ""
        } else {
            return "?" + queryString
        }
    }
    
}
