import Foundation

public class Etherscan: BlockExplorer {
    
    struct JsonResponse: Codable {
        let status: String
        let message: String
        let result: String
        enum CodingKeys: String, CodingKey {
            case status, message, result
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
            return "https://api.etherscan.io/api"
        } else {
            return "https://api-ropsten.etherscan.io/api"
        }
    }
    
    public override func getAddressWebLink(addr: String) -> String { // todo: use address instead of addr
        let webUrl: String
        if (self.coinSymbol == "ETH"){
            webUrl = "https://etherscan.io/address/"+addr
        } else {
            webUrl = "https://ropsten.etherscan.io/address/"+addr
        }
        return webUrl
    }
    
    public override func getTokenWebLink(contract: String) -> String {
        // https://etherscan.io/token/0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb
        let webUrl: String
        if (self.coinSymbol == "ETH"){
            webUrl = "https://etherscan.io/token/"+contract
        } else {
            webUrl = "https://ropsten.etherscan.io/token/"+contract
        }
        return webUrl
    }
    
    /// Make network request using async `URLSession` API
    @available(iOS 15.0, *)
    public override func getBalance(addr: String) async throws -> Double {
        print("in Etherscan getBalance - addr: \(addr)")
        
//        https://api.etherscan.io/api
//                    ?module=account
//                    &action=balance
//                    &address=0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae
//                    &tag=latest
//                    &apikey=YourApiKeyToken
//        {"status":"1","message":"OK","result":"353318436783144397866641"}
        
        let apikey = self.apiKeys["API_KEY_ETHERSCAN"] ?? ""
        let urlString: String = self.getUrl()
                                        + "?module=account&action=balance&address="
                                        + addr //"0x0dE8bf93dA2f7eecb3d9169422413A9bef4ef628" //addr
                                        + "&tag=latest&apikey="
                                        + apikey
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponse.self, from: data)
        print("result: \(result)")
        
        guard let balanceInt = Double(result.result) else {
            throw DataFetcherError.missingData
        }
        print("balanceInt: \(balanceInt)")
        let balance: Double = balanceInt/pow(Double(10), Double(18))
        return balance
    }

    @available(iOS 15.0.0, *)
    public override func getTokenBalance(addr: String, contract: String) async throws -> Double {
        print("in Etherscan getTokenBalance - addr: \(addr)")
        /*
            https://api.etherscan.io/api
               ?module=account
               &action=tokenbalance
               &contractaddress=0x57d90b64a1a57749b0f932f1a3395792e12e7055
               &address=0xe04f27eb70e025b78871a2ad7eabe85e61212761
               &tag=latest&apikey=YourApiKeyToken
               
               {"status":"1","message":"OK","result":"135499"}
         */
        
        let apikey = self.apiKeys["API_KEY_ETHERSCAN"] ?? ""
        let urlString: String = self.getUrl()
                                        + "?module=account&action=tokenbalance&contractaddress="
                                        + contract
                                        + "&address="
                                        + addr //"0x0dE8bf93dA2f7eecb3d9169422413A9bef4ef628" //addr
                                        + "&tag=latest&apikey="
                                        + apikey
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponse.self, from: data)
        print("result: \(result)")
        
        guard let balanceInt = Double(result.result) else {
            throw DataFetcherError.missingData
        }
        print("balanceInt: \(balanceInt)")
        
        // most ERC20 use 18 decimals but etherscan does not offer reliable way to find out...
        let tokenInfo = try await self.getTokenInfo(contract: contract)
        let decimalsString = tokenInfo["decimals"] ?? "0"
        guard let decimals = Double(decimalsString) else {
            throw DataFetcherError.missingData
        }
        
        let balance: Double = balanceInt/pow(Double(10), decimals)
        return balance
    }
    
    @available(iOS 15.0.0, *)
    public override func getTokenInfo(contract: String) async throws -> [String : String] {
        print("in Etherscan getTokenInfo - contract: \(contract)")
        
        //https://github.com/EverexIO/Ethplorer/wiki/Ethplorer-API#get-token-info
        var tokenInfo: [String : String] = [:]
        tokenInfo["name"] = "(unknown)"
        tokenInfo["symbol"] = "(unknown)"
        tokenInfo["decimals"] = ""
        
        let apikey = self.apiKeys["API_KEY_ETHPLORER"] ?? ""
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
