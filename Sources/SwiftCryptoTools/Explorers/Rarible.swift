import Foundation

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
        
        let urlString: String = self.getUrl() + "nft/items/"+contract+":" + tokenid + "/meta"
        print("urlString: \(urlString)")
        
        do {
            let url = URL(string: urlString)
            
            // Use the async variant of URLSession to fetch data
            let (data, _) = try await URLSession.shared.data(from: url!)
            
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
        } catch {
            print("Unexpected error: \(error)")
        }
        
        return nftInfo
    }
    
}
