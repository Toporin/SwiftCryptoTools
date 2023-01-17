import Foundation

public class Opensea: NftExplorer {
    
    struct JsonResponseNftInfo: Codable {
        let name: String
        let description: String
        let image_url: String?
        let image_preview_url: String?
        let image_thumbnail_url: String?
        let image_original_url: String?
        enum CodingKeys: String, CodingKey {
            case name, description, image_url, image_preview_url, image_thumbnail_url, image_original_url
        }
    }
    
    public func getUrl() -> String {
        return "https://api.opensea.io/api/v1/"
    }
    
    public override func getNftOwnerWeburl(addr: String) -> String {
        // https://opensea.io/0x800b4dbcef65cb5d1b2f8e33d5d0bbcbffea2a8e
        return "https://opensea.io/" + addr
    }
        
    public override func getNftWeburl(contract: String, tokenid: String) -> String {
        return "https://opensea.io/assets/" + contract  + "/" + tokenid
    }
    
    @available(iOS 15.0.0, *)
    public override func getNftInfo(contract: String, tokenid: String) async throws -> [String:String] {
        
        // https://api.opensea.io/api/v1/asset/0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb/1/?account_address=0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb
        
        var nftInfo: [String:String] = [:]
        nftInfo["nftName"] = ""
        nftInfo["nftDescription"] = ""
        nftInfo["nftImageUrl"] = ""
        nftInfo["nftExplorerLink"] = ""
        
        let urlString: String = self.getUrl() + "asset/"+contract+"/" + tokenid + "/"
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }
        
        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseNftInfo.self, from: data)
        print("result: \(result)")
        
        nftInfo["nftName"] = result.name
        nftInfo["nftDescription"] = result.description
        nftInfo["nftExplorerLink"] = self.getNftWeburl(contract: contract, tokenid: tokenid)
        nftInfo["nftImageUrl"] = result.image_thumbnail_url
        nftInfo["nftImageUrlLarge"] = result.image_url
        if result.image_thumbnail_url != nil {
            nftInfo["nftImageUrl"] = result.image_thumbnail_url
        } else if result.image_preview_url != nil {
            nftInfo["nftImageUrl"] = result.image_preview_url
        } else if result.image_url != nil {
            nftInfo["nftImageUrl"] = result.image_url
        } else if result.image_original_url != nil {
            nftInfo["nftImageUrl"] = result.image_original_url
        } else {
            nftInfo["nftImageUrl"] = ""
        }
        
        return nftInfo
    }
}
