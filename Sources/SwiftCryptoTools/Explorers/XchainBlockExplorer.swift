import Foundation
import BigInt

public class XchainBlockExplorer: BlockExplorer {
    
    struct JsonResponseBalance: Codable {
        let xcpBalance: String
        enum CodingKeys: String, CodingKey {
            case xcpBalance = "xcp_balance"
        }
    }
    
    struct JsonResponseTokenBalance: Codable {
        let address: String
        let data: [AssetData]
        let total: UInt
        enum CodingKeys: String, CodingKey {
            case address, data, total
        }
    }
    
    struct AssetData: Codable {
        let asset: String
        let asset_longname: String
        let description: String
        let quantity: String
        let estimated_value: ValueData
        enum CodingKeys: String, CodingKey {
            case asset, asset_longname, description, quantity, estimated_value
        }
    }
    
    struct ValueData: Codable {
        let xcp: String
        let btc: String
        let usd: String
        enum CodingKeys: String, CodingKey {
            case xcp, btc, usd
        }
    }
    
    public var nftExplorer: XchainNftExplorer
    
    public override init(coinSymbol: String, apiKeys: [String:String]){
        self.nftExplorer = XchainNftExplorer(coinSymbol: coinSymbol, apiKeys: apiKeys)
        super.init(coinSymbol: coinSymbol, apiKeys: apiKeys)
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
    
    public override func getAddressWebLink(addr: String) -> String {
        return self.getUrl() + "address/" + addr
    }
    
    public override func getTokenWebLink(contract: String) -> String {
        return self.getUrl() + "asset/" + contract
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
    public override func getAssetList(addr: String) async throws -> [String:[[String:String]]] {
        print("in XchainBlockExplorer getAssetList - addr: \(addr)")
        
        let urlString: String = self.getUrl() + "api/balances/" +  addr
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }
        
        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseTokenBalance.self, from: data)
        print("result: \(result)")
        
        var assetList: [String:[[String:String]]] = [:]
        assetList["coin"]=[]
        assetList["token"]=[]
        assetList["nft"]=[]
        
        for item in result.data {
            var assetType: String = "token"
            var assetData: [String:String] = [:]
            //assetData["asset"] = item.asset
            assetData["balance"] = item.quantity
            // tokenInfo
            do {
                var tokenInfo = try await self.getTokenInfo(contract: item.asset)
                if let assetName = tokenInfo["name"] {
                    if assetName == "XCP" {
                        assetType = "coin"
                        assetData["type"] = "coin"
                    } else {
                        assetType = "token"
                        assetData["type"] = "token"
                    }
                }
                assetData = assetData.merging(tokenInfo, uniquingKeysWith: { (first, _) in first })
            } catch {
                print("failed to fetch info for token: \(item.asset)")
            }
            // NFT info?
            do {
                var nftInfo = try await self.nftExplorer.getNftInfo(contract: item.asset, tokenid:"")
                if let nftImageUrl = nftInfo["nftImageUrl"] {
                    if nftImageUrl != "" {
                        assetType = "nft"
                        assetData["type"] = "nft"
                    }
                }
                assetData = assetData.merging(nftInfo, uniquingKeysWith: { (first, _) in first })
            } catch {
                print("failed to fetch infor for nft: \(item.asset)")
            }
            //assetList.append(assetData)
            assetList[assetType]?.append(assetData)
            print("assetType: \(assetType)")
        }
        print("assetList: \(assetList)")
        return assetList
    }
    
    @available(iOS 15.0.0, *)
    public override func getSimpleAssetList(addr: String) async throws -> [[String:String]] {
        print("in XchainBlockExplorer getSimpleAssetList - addr: \(addr)")
        
        let urlString: String = self.getUrl() + "api/balances/" +  addr
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }
        
        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseTokenBalance.self, from: data)
        print("result: \(result)")
        
        var assetList: [[String:String]] = []
        for item in result.data {
            // skip XCP as its not a token but the native 'coin' of counterparty
            if item.asset == "XCP" {
                continue
            }
            
            var assetData: [String:String] = [:]
            assetData["balance"] = item.quantity
            assetData["decimals"] = "0"
            assetData["contract"] = item.asset
            assetData["name"] = item.asset
            assetData["type"] = "token" //by default
            assetData["tokenExplorerLink"] = getTokenWebLink(contract: item.asset)
            
            // exchange rate
            let valueData = item.estimated_value
            let usdValueString = valueData.usd
            if let usdValueDouble = Double(usdValueString),
               let quantityDouble = Double(item.quantity) {
                let exchangeRateDouble = usdValueDouble/quantityDouble
                let exchangeRateString = String(exchangeRateDouble)
                assetData["tokenExchangeRate"] = exchangeRateString
                assetData["currencyForExchangeRate"] = "USD"
            }
            
            assetList.append(assetData)
        }
        print("assetList: \(assetList)")
        return assetList
    }
    
//    @available(iOS 15.0.0, *)
//    public override func getTokenList(addr: String) async throws -> [AssetInfo] {
//        print("in XchainBlockExplorer getSimpleAssetList - addr: \(addr)")
//
//        let urlString: String = self.getUrl() + "api/balances/" +  addr
//        guard let url = URL(string: urlString) else {
//            throw DataFetcherError.invalidURL
//        }
//
//        // Use the async variant of URLSession to fetch data
//        let (data, _) = try await URLSession.shared.data(from: url)
//
//        // Parse the JSON data
//        let result = try JSONDecoder().decode(JsonResponseTokenBalance.self, from: data)
//        print("result: \(result)")
//
//        //var assetList: [String:[[String:String]]] = [:]
//        var assetList: [AssetInfo] = []
//
//        for item in result.data {
//            //var assetType: String = "token"
//            var assetData: AssetInfo = AssetInfo()
//            //assetData["asset"] = item.asset
//            assetData.balance = BigInt(item.quantity) // string to BigInt?
//            assetData.decimals = 0
//            assetData.contract = item.asset
//            assetData.type = AssetType.token // by default, will be updated later?
//            assetList.append(assetData)
//        }
//        print("assetList: \(assetList)")
//        return assetList
//    }
    
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
        
        var balanceString: String? = "0"
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

