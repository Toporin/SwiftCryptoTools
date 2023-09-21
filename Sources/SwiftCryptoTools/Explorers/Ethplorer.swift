import Foundation

public class Ethplorer: BlockExplorer {
    
    // api doc: https://github.com/EverexIO/Ethplorer/wiki/Ethplorer-API
    
    struct JsonResponseAddrInfo: Codable {
        let address: String
        let ETH: CoinData
        let tokens: [TokenData]?
        enum CodingKeys: String, CodingKey {
            case address, ETH, tokens
        }
    }
    
    struct CoinData: Codable {
        let balance: Double // in eth/bsc
        let rawBalance: String // in wei
        enum CodingKeys: String, CodingKey {
            case balance, rawBalance
        }
    }
    
    struct TokenData: Codable {
        let tokenInfo: TokenInfo
        let balance: Double
        let rawBalance: String
        enum CodingKeys: String, CodingKey {
            case tokenInfo, balance, rawBalance
        }
    }
    
    struct TokenInfo: Codable {
        let address: String
        let name: String
        let decimals: String?
        let symbol: String
        let totalSupply: String
        //"owner":"","lastUpdated":1602678250,"issuancesCount":0,"holdersCount":8717,"ethTransfersCount":0,"price":false
        enum CodingKeys: String, CodingKey {
            case address, name, decimals, symbol, totalSupply
        }
    }
    
    public var nftExplorer: Rarible
    
    public override init(coinSymbol: String, apiKeys: [String:String]){
        self.nftExplorer = Rarible(coinSymbol: coinSymbol, apiKeys: apiKeys)
        super.init(coinSymbol: coinSymbol, apiKeys: apiKeys)
    }
    
    public func getUrl() -> String {
        if self.coinSymbol == "ETH" {
            return "https://api.ethplorer.io/"
        } else if self.coinSymbol == "BSC"{
            return "https://api.binplorer.com/"
        } else if self.coinSymbol == "tETH" {
            return "https://goerli-api.ethplorer.io/"
        } else {
            //todo throw CoinError.UnsupportedCoinError
            return "https://api.ethplorer.io/"
        }
    }
    
    public func getCoinName() -> String {
        if self.coinSymbol == "ETH" {
            return "Ethereum"
        } else if self.coinSymbol == "BSC"{
            return "BinanceSmartChain"
        } else if self.coinSymbol == "tETH" {
            return "Goerli testnet"
        } else {
            return self.coinSymbol
        }
    }
    
    public override func getAddressWebLink(addr: String) -> String { // todo: use address instead of addr
        // https://ethplorer.io/address/{address}
        let webUrl: String
        if (self.coinSymbol == "ETH"){
            webUrl = "https://ethplorer.io/address/" + addr
        } else if (self.coinSymbol == "BSC") {
            webUrl = "https://api.binplorer.com/address/" + addr
        } else {
            webUrl = "https://goerli.ethplorer.io/address/" + addr
        }
        return webUrl
    }
    
    public override func getTokenWebLink(contract: String) -> String {
        // https://ethplorer.io/address/{address}
        return self.getAddressWebLink(addr: contract)
    }
    
    /// Make network request using async `URLSession` API
    @available(iOS 15.0, *)
    public override func getBalance(addr: String) async throws -> Double {
        print("in Ethplorer getBalance - addr: \(addr)")
        
        let apikey: String = self.apiKeys["API_KEY_ETHPLORER"] ?? ""
        let urlString: String = self.getUrl()
            + "getAddressInfo/"
            + addr
            + "?apiKey="
            + apikey
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseAddrInfo.self, from: data)
        print("result: \(result)")
        
        return result.ETH.balance
    }

    @available(iOS 15.0.0, *)
    public override func getAssetList(addr: String) async throws -> [String:[[String:String]]] {
        print("in Ethplorer getAssetList - addr: \(addr)")
        
        //https://api.ethplorer.io/getAddressInfo/0x2Ff9d7c0b98E0DeC39bF15568fe0864967583C44?apiKey=freekey
        let apikey: String = self.apiKeys["API_KEY_ETHPLORER"] ?? ""
        let urlString: String = self.getUrl()
            + "getAddressInfo/"
            + addr
            + "?apiKey="
            + apikey
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseAddrInfo.self, from: data)
        print("result: \(result)")
        
        //var assetList: [[String:String]] = []
        var assetList: [String:[[String:String]]] = [:]
        assetList["coin"]=[]
        assetList["token"]=[]
        assetList["nft"]=[]
        
        // ETH/BSC token
        var assetData: [String:String] = [:]
        assetData["type"] = "coin"
        assetData["name"] = self.getCoinName()
        assetData["symbol"] = self.coinSymbol
        assetData["balance"] = result.ETH.rawBalance
        assetData["decimals"] = "18"
        assetList["coin"]?.append(assetData)
        
        // other tokens: erc20, erc721 & erc1155 are mixed
        // no tokenId are provided...
        for item in result.tokens ?? [] {
            
            // token info
            var assetData: [String:String] = [:]
            assetData["type"] = "token"
            assetData["name"] = item.tokenInfo.name
            assetData["contract"] = item.tokenInfo.address
            assetData["symbol"] = item.tokenInfo.symbol
            assetData["decimals"] = item.tokenInfo.decimals ?? "0"
            assetData["balance"] = item.rawBalance
            // check via rarible if asset is an nft
            do {
                let nftList = try await self.nftExplorer.getNftList(addr: addr, contract: item.tokenInfo.address)
                for nft in nftList {
                    if let nftImageUrl = nft["nftImageUrl"] {
                        if nftImageUrl != "" {
                            assetData["type"] = "nft"
                        }
                    }
                    assetData = assetData.merging(nft, uniquingKeysWith: { (first, _) in first })
                }
            } catch {
                print("failed to fetch infor for nft: \(item.tokenInfo.address)")
            }
            //assetList.append(assetData)
            print("assetData[type]: \(assetData["type"])")
            if assetData["type"] == "token" {
                assetList["token"]?.append(assetData)
            } else {
                assetList["nft"]?.append(assetData)
            }
            
        }
        print("assetList: \(assetList)")
        return assetList
    }
    
    @available(iOS 15.0.0, *)
    public override func getSimpleAssetList(addr: String) async throws -> [[String:String]] {
        print("in Ethplorer getSimpleAssetList - addr: \(addr)")
        
        //https://api.ethplorer.io/getAddressInfo/0x2Ff9d7c0b98E0DeC39bF15568fe0864967583C44?apiKey=freekey
        let apikey: String = self.apiKeys["API_KEY_ETHPLORER"] ?? ""
        let urlString: String = self.getUrl()
            + "getAddressInfo/"
            + addr
            + "?apiKey="
            + apikey
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseAddrInfo.self, from: data)
        print("result: \(result)")
        
        var assetList: [[String:String]] = []
        
        // ETH/BSC token
        // we do not include native currency in the list
        // for modularity, it is part of another request...
//        var assetData: [String:String] = [:]
//        assetData["type"] = "coin"
//        assetData["name"] = self.getCoinName()
//        assetData["symbol"] = self.coinSymbol
//        assetData["balance"] = result.ETH.rawBalance
//        assetData["decimals"] = "18"
//        //assetList.append(assetData)
//        //assetList["coin"]=[assetData]
//        assetList["coin"]?.append(assetData)
        
        // other tokens: erc20, erc721 & erc1155 are all mixed
        // no tokenId are provided...
        for item in result.tokens ?? [] {
            
            // token info
            var assetData: [String:String] = [:]
            assetData["type"] = "token" // by default
            assetData["name"] = item.tokenInfo.name
            assetData["contract"] = item.tokenInfo.address
            assetData["symbol"] = item.tokenInfo.symbol
            assetData["decimals"] = item.tokenInfo.decimals ?? "0"
            assetData["balance"] = item.rawBalance
            // to get nft info, we use another method getNftList(addr: String, contract: String) from NftExplorer class
            assetList.append(assetData)
        }
        print("assetList: \(assetList)")
        return assetList
    }
    
    @available(iOS 15.0.0, *)
    public override func getTokenBalance(addr: String, contract: String) async throws -> Double {
        print("in Ethplorer getTokenBalance - addr: \(addr)")
        /*
         https://api.ethplorer.io/getAddressInfo/0xff71cb760666ab06aa73f34995b42dd4b85ea07b?token=0xdac17f958d2ee523a2206206994597c13d831ec7&apiKey=freekey
         */
        
        let apikey = self.apiKeys["API_KEY_ETHPLORER"] ?? ""
        let urlString: String = self.getUrl()
            + "getAddressInfo/"
            + addr
            + "?token="
            + contract
            + "&apiKey="
            + apikey
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseAddrInfo.self, from: data)
        print("result: \(result)")
        
        if let tokens = result.tokens {
            if tokens.count>=1 {
                let token = tokens[0]
                guard let decimals = Double(token.tokenInfo.decimals ?? "0") else {
                    throw DataFetcherError.missingData
                }
                guard let balanceInt  = Double(token.rawBalance) else {
                    throw DataFetcherError.missingData
                }
                let balance: Double = balanceInt/pow(Double(10), decimals)
                return balance
            } else {
                //throw DataFetcherError.missingData
                return 0
            }
        } else {
            //throw DataFetcherError.missingData
            return 0
        }
    }
    
    @available(iOS 15.0.0, *)
    public override func getTokenInfo(contract: String) async throws -> [String : String] {
        print("in Ethplorer getTokenInfo - contract: \(contract)")
        
        //https://github.com/EverexIO/Ethplorer/wiki/Ethplorer-API#get-token-info
        var tokenInfo: [String : String] = [:]
        tokenInfo["name"] = "(unknown)"
        tokenInfo["symbol"] = "(unknown)"
        //tokenInfo["decimals"] = ""
        
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
        let result = try JSONDecoder().decode(TokenInfo.self, from: data)
        print("result: \(result)")
        
        tokenInfo["name"] = result.name
        tokenInfo["symbol"] = result.symbol
        tokenInfo["decimals"] = result.decimals
        tokenInfo["totalSupply"] = result.totalSupply
        tokenInfo["address"] = result.address
        return tokenInfo
    }
    
}

