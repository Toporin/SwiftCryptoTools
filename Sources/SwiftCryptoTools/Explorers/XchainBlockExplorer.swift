import Foundation

public class XchainBlockExplorer: BlockExplorer {
    
    struct JsonResponseBalance: Codable {
        let xcpBalance: String
        enum CodingKeys: String, CodingKey {
            case xcpBalance = "xcp_balance"
        }
    }
    
    struct JsonResponseTokenBalance: Codable {
        let address: String
        let data: [BalanceData]
        let total: UInt
        enum CodingKeys: String, CodingKey {
            case address, data, total
        }
    }
    
    struct BalanceData: Codable {
        let asset: String
        let asset_longname: String
        let description: String
        let quantity: String
        enum CodingKeys: String, CodingKey {
            case asset, asset_longname, description, quantity
        }
    }
    
    
    public func getUrl() -> String {
        if self.coinSymbol == "XCP" {
            return  "https://xchain.io/"
        } else if self.coinSymbol == "XCPTEST" {
            return "https://testnet.xchain.io/"
        } else if self.coinSymbol == "XDP" {
            return "https://dogeparty.xchain.io/"
        } else if self.coinSymbol == "XDPTEST" {
            return "https://dogeparty-testnet.xchain.io/"
        } else {
            return "https://notfound.org/"
        }
    }
    
    public override func getAddressWeburl(addr: String) -> String {
        return self.getUrl() + "address/" + addr
    }
    
    /// Make network request using async `URLSession` API
    @available(iOS 15.0, *)
    public override func getBalance(addr: String) async throws -> Double {
        print("In XchainBlockExplorer getBalance for: \(addr)")
        
        // doc: https://xchain.io/api#address
        let urlString: String = self.getUrl() + "api/address/" + addr
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        //print("data: \(data)")
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseBalance.self, from: data)
        print("result: \(result)")
        
        let balance: Double = Double(result.xcpBalance)!
        return balance
    }
    
    @available(iOS 15.0.0, *)
    public override func getTokenBalance(addr: String, contract: String) async throws -> Double {
        print("in XchainBlockExplorer getTokenBalance - addr: \(addr)")
        
        let urlString: String = self.getUrl() + "api/balances/" +  addr
                                        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseTokenBalance.self, from: data)
        print("result: \(result)")
        
        var balanceString: String? = nil
        for item in result.data {
            if item.asset == contract {
                balanceString = item.quantity
                break
            }
        }
        
        if let balanceString = balanceString {
            guard let balanceDouble = Double(balanceString) else {
                throw DataFetcherError.missingData
            }
            print("balanceDouble: \(balanceDouble)")
            return balanceDouble
        } else {
            throw DataFetcherError.missingData
        }
    }
    
    @available(iOS 15.0.0, *)
    public override func getTokenInfo(contract: String) async throws -> [String : String] {
        print("in XchainBlockExplorer getTokenInfo - contract: \(contract)")
        var tokenInfo: [String : String] = [:]
        tokenInfo["name"] = contract
        tokenInfo["symbol"] = ""
        tokenInfo["decimals"] = "0"
        return tokenInfo
    }

}

