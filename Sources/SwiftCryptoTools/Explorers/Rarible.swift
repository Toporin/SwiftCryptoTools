import Foundation

public struct NftList: Codable {
    let total: Int
    let ownerships: [NftRef]
    enum CodingKeys: String, CodingKey {
        case total, ownerships
    }
}

public struct NftRef: Codable {
    let id: String
    let tokenId: String
    let owner: String
    let contract: String
    let value: String
    enum CodingKeys: String, CodingKey {
        case id, tokenId, owner, contract, value
    }
}

public class Rarible: NftExplorer {
    
    struct ImageInfo: Codable {
        let type: String
        let representation: String
        let url: String
        enum CodingKeys: String, CodingKey {
            case type = "@type", representation, url
        }
    }

    struct JsonResponseNftInfo: Codable {
        let name: String
        let description: String?
        let content: [ImageInfo]
        enum CodingKeys: String, CodingKey {
            case name, description, content
        }
    }
    
    public func getUrl() -> String {
        if self.coinSymbol == "ETH" {
            return "https://ethereum-api.rarible.org/v0.1/"
        } else {
            return "https://ethereum-api-dev.rarible.org/v0.1/"
        }
    }
    
    public override func getNftOwnerWebLink(addr: String) -> String {
        // https://rarible.com/user/0xb3f8dae49c7f0e94d434db6088683c12d31a621f/owned
        return "https://rarible.com/user/" + addr + "/owned"
    }
        
    public override func getNftWebLink(contract: String, tokenid: String) -> String {
        return "https://rarible.com/token/" + contract  + ":" + tokenid
    }
    
    @available(iOS 15.0.0, *)
    public override func getNftInfo(contract: String, tokenid: String) async throws -> [String:String] {
        
        // https://ethereum-api.rarible.org/v0.1/doc#tag/nft-item-controller
        // https://ethereum-api.rarible.org/v0.1/nft/items/{itemId}/meta
        
        var nftInfo: [String:String] = [:]
        nftInfo["nftName"] = ""
        nftInfo["nftDescription"] = ""
        nftInfo["nftImageUrl"] = ""
        nftInfo["nftExplorerLink"] = ""
        
        let apikey = self.apiKeys["API_KEY_RARIBLE"] ?? ""
        let urlString: String = self.getUrl() + "nft/items/"+contract+":" + tokenid + "/meta"
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
        let result = try JSONDecoder().decode(JsonResponseNftInfo.self, from: data)
        print("result: \(result)")
    
        nftInfo["nftName"] = result.name
        nftInfo["nftDescription"] = result.description ?? ""
        nftInfo["nftExplorerLink"] = self.getNftWebLink(contract: contract, tokenid: tokenid)
        
        // image priority: original > preview > big ?
        for item in result.content {
            if item.representation == "ORIGINAL" {
                nftInfo["nftImageUrl"] = item.url
                break
            } else if item.representation == "PREVIEW" {
                nftInfo["nftImageUrl"] = item.url
            } else if item.representation == "BIG" && nftInfo["nftImageUrl"] == "" {
                nftInfo["nftImageUrl"] = item.url
            }
        }

        return nftInfo
    }
 
//    //
//    @available(iOS 15.0.0, *)
//    public func getNftListOld(addr: String, contract: String) async throws -> NftList {
//
//        print("in Rarible getNftList - addr: \(addr)")
//
//        //https://ethereum-api.rarible.org/v0.1/nft/ownerships/byOwner?owner=0xb51f56dbec3505e00f53015d4aa077469c2a2a31&collection=0x60f80121c31a0d46b5279700f9df786054aa5ee5
//        let apikey = self.apiKeys["API_KEY_RARIBLE"] ?? ""
//        let urlString: String = self.getUrl()
//                                    + "nft/ownerships/byOwner?owner="
//                                    + addr
//                                    + "&collection="
//                                    + contract
//        print("urlString: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw DataFetcherError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue(apikey, forHTTPHeaderField: "X-API-KEY")
//
//        // Use the async variant of URLSession to fetch data
//        //let (data, _) = try await URLSession.shared.data(from: url)
//        let (data, _) = try await URLSession.shared.data(for: request)
//        print("data: \(data)")
//
//        // Parse the JSON data
//        let result = try JSONDecoder().decode(NftList.self, from: data)
//        print("result: \(result)")
//
//        return result
//
//    }
    
    @available(iOS 15.0.0, *)
    public override func getNftList(addr: String, contract: String) async throws -> [[String:String]] {
        
        print("in Rarible getNftList - addr: \(addr)")
        
        //https://ethereum-api.rarible.org/v0.1/nft/ownerships/byOwner?owner=0xb51f56dbec3505e00f53015d4aa077469c2a2a31&collection=0x60f80121c31a0d46b5279700f9df786054aa5ee5
        let apikey = self.apiKeys["API_KEY_RARIBLE"] ?? ""
        let urlString: String = self.getUrl()
                                    + "nft/ownerships/byOwner?owner="
                                    + addr
                                    + "&collection="
                                    + contract
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apikey, forHTTPHeaderField: "X-API-KEY")
        
        // Use the async variant of URLSession to fetch data
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        print("data: \(data)")
        //print("urlResponse: \(urlResponse)")
        // todo: check status code 429: too many requests and handle it?
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(NftList.self, from: data)
        print("result: \(result)")
        
        var nftList: [[String:String]] = []
        for nftRef in result.ownerships {
            
            var nft: [String:String]=[:]
            nft["contract"] = nftRef.contract
            nft["tokenid"] = nftRef.tokenId
            nft["balance"] = nftRef.value // balance?
            
            let nftInfo = try await getNftInfo(contract: nftRef.contract, tokenid: nftRef.tokenId)
            nft.merge(nftInfo, uniquingKeysWith: { (first, _) in first })
            nftList.append(nft)
        }

        return nftList
    }
    
}
