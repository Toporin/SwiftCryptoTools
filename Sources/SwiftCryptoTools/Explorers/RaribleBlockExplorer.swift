import Foundation

// Deprecated
public class RaribleBlockExplorer: BlockExplorer {
    
    struct JsonResponseGetBalance: Codable {
        let owner: String
        let balance: Int
        let decimalBalance: Double
        enum CodingKeys: String, CodingKey {
            case owner, balance, decimalBalance
        }
    }
    
    struct JsonResponseTokenInfo: Codable {
        let address: String
        let totalSupply: String
        let name: String
        let symbol: String
        let decimals: String
        enum CodingKeys: String, CodingKey {
            case address, totalSupply, name, symbol, decimals
        }
    }
    
    public func getUrl() -> String {
        if self.coinSymbol == "ETH" {
            return "https://ethereum-api.rarible.org/v0.1/"
        } else {
            return "https://testnet-api.rarible.org/v0.1/" // todo?
        }
    }
    
    public override func getAddressWebLink(addr: String) -> String { // todo: use address instead of addr
        let webUrl: String
        if (self.coinSymbol == "ETH"){
            // https://rarible.com/user/0x1fee3385b22d69e93209db2042be58fcac57b59b/owned
            webUrl = "https://rarible.com/user/" + addr + "/owned"
        } else {
            webUrl = "https://testnet.rarible.com/user/" + addr + "/owned"
        }
        return webUrl
    }
    
    public override func getTokenWebLink(contract: String) -> String {
        // https://etherscan.io/token/0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb
        // for rarible, needs a tokenid (nft)
        let webUrl: String
        if (self.coinSymbol == "ETH"){
            //https://rarible.com/collection/0x9c8ff314c9bc7f6e59a9d9225fb22946427edc03/items
            webUrl = "https://rarible.com/collection/" + contract + "/items"
        } else {
            webUrl = "https://testnet.rarible.com/collection/" + contract + "/items"
        }
        return webUrl
    }
    
    /// Make network request using async `URLSession` API
    @available(iOS 15.0, *)
    public override func getBalance(addr: String) async throws -> Double {
        print("in RaribleBlockExplorer getBalance - addr: \(addr)")
        
        //https://ethereum-api.rarible.org/v0.1/erc20/balances/eth/0x60f80121c31a0d46b5279700f9df786054aa5ee5
        let apikey = self.apiKeys["API_KEY_RARIBLE"] ?? ""
        let urlString: String = self.getUrl()
                                    + "erc20/balances/eth/" + addr
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apikey, forHTTPHeaderField: "X-API-KEY")
        
        // Use the async variant of URLSession to fetch data
        //let (data, _) = try await URLSession.shared.data(from: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseGetBalance.self, from: data)
        print("result: \(result)")
        
        return result.decimalBalance
    }

    @available(iOS 15.0.0, *)
    public override func getTokenBalance(addr: String, contract: String) async throws -> Double {
        print("in RaribleBlockExplorer getTokenBalance - addr: \(addr)")
        
        // https://ethereum-api.rarible.org/v0.1/erc20/balances/{contract}/{owner}
        let apikey = self.apiKeys["API_KEY_RARIBLE"] ?? ""
        let urlString: String = self.getUrl()
                                    + "erc20/balances/"
                                    + contract
                                    + "/"
                                    + addr
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apikey, forHTTPHeaderField: "X-API-KEY")
        
        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseGetBalance.self, from: data)
        print("result: \(result)")
        
        return result.decimalBalance
    }
    
    @available(iOS 15.0.0, *)
    public override func getTokenInfo(contract: String) async throws -> [String : String] {
        print("in RaribleBlockExplorer getTokenInfo - contract: \(contract)")
        
        // todo: API does not work properly??
        //https://github.com/EverexIO/Ethplorer/wiki/Ethplorer-API#get-token-info
        var tokenInfo: [String : String] = [:]
        tokenInfo["name"] = "(unknown)"
        tokenInfo["symbol"] = "(unknown)"
        tokenInfo["decimals"] = ""
        
        let apikey = self.apiKeys["API_KEY_RARIBLE"] ?? ""
        let baseUrl = "https://api.ethplorer.io"
        let urlString: String = baseUrl + "/getTokenInfo/" + contract + "?apiKey=" + apikey
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseTokenInfo.self, from: data)
        print("result: \(result)")
        
        tokenInfo["name"] = result.name
        tokenInfo["symbol"] = result.symbol
        tokenInfo["decimals"] = result.decimals
        tokenInfo["totalSupply"] = result.totalSupply
        tokenInfo["address"] = result.address
        return tokenInfo
    }
    
}

