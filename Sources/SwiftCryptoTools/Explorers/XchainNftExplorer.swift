import Foundation

public class XchainNftExplorer: NftExplorer {
    
    // https://xchain.io/api#parameters-address
    struct JsonResponseNftInfo: Codable {
        let asset: String
        let asset_longname: String
        let description: String
        let divisible: Bool
        let locked: Bool
        //let supply: String //UInt64
        let type: String
        enum CodingKeys: String, CodingKey {
            case asset, asset_longname, description, divisible, locked, type //supply
        }
    }
    
    struct JsonResponseJsonLink: Codable {
        let image: String?
        let image_large: String?
        enum CodingKeys: String, CodingKey {
            case image, image_large
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
    
    public override func getNftOwnerWebLink(addr: String) -> String {
        return self.getUrl() + "address/" + addr
    }
        
    public override func getNftWebLink(contract: String, tokenid: String) -> String {
        return self.getUrl() + "asset/" + contract
    }
    
    @available(iOS 15.0.0, *)
    public override func getNftList(addr: String, contract: String) async throws -> [[String:String]] {
        // ignore tokenId for Counterparty
        // we assume addr does possess the NFT assset, as provided by getAssetList(addr: String)
        let nftInfo = try await self.getNftInfo(contract: contract, tokenid: "")
        if nftInfo["nftImageUrl"] != nil{
            return [nftInfo]
        } else {
            // only returns if nft...
            return []
        }
    }
    
    @available(iOS 15.0.0, *)
    public override func getNftInfo(contract: String, tokenid: String) async throws -> [String:String] {
        
        var nftInfo: [String:String] = [:]
        nftInfo["name"] = contract
        nftInfo["contract"] = contract
        //nftInfo["nftDescription"] = ""
        //nftInfo["nftImageUrl"] = ""
        nftInfo["nftExplorerLink"] = self.getNftWebLink(contract: contract, tokenid: "")
        
        // tokenid is not used...
        let urlString: String = self.getUrl() + "api/asset/" + contract
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }
        
        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        do {
            let result = try JSONDecoder().decode(JsonResponseNftInfo.self, from: data)
            print("result: \(result)")
            
            let divisible = String(result.divisible)
            let locked = String(result.locked)
            //let supply = result.supply
            var descriptionTxt: String = "Divisible: \(divisible) \n" +
                                         "Locked: \(locked) \n" +
                                         //"Supply: \(supply) \n" +
                                         "Description: \(result.description)"
            nftInfo["nftDescription"] = descriptionTxt
            
            // parse description field to extract data & image link
            var link: String = result.description
            if link.hasPrefix("*") {
                link = String(link.dropFirst(1))
            }
            if link.hasPrefix("imgur/") {
                link = String(link.dropFirst(6)) // remove "imgur/"
                let parts = link.components(separatedBy: ";")
                link = "https://i.imgur.com/" + parts[0]
                nftInfo["nftImageUrl"] = link
                print("link: \(link)")
            } else if link.hasPrefix("https://") || link.hasPrefix("http://"){
                if link.hasSuffix(".png") ||
                    link.hasSuffix(".jpg") ||
                    link.hasSuffix(".jpeg") ||
                    link.hasSuffix(".gif") {
                        nftInfo["nftImageUrl"] = link
                } else if link.hasSuffix(".json"){
                    // fetch JSON data from link
                    guard let url2 = URL(string: link) else {
                        print("Error with link: \(link)")
                        throw DataFetcherError.invalidURL
                    }
                    // Use the async variant of URLSession to fetch data
                    let (data2, _) = try await URLSession.shared.data(from: url2)
                    let result2 = try JSONDecoder().decode(JsonResponseJsonLink.self, from: data2)
                    print("result2: \(result2)")
                    if result2.image_large != nil {
                        nftInfo["nftImageUrl"] = result2.image_large
                    } else if result2.image != nil {
                        nftInfo["nftImageUrl"] = result2.image
                    }
                    // todo: add json data in description?
                }
            }
        } catch {
            print("Error: \(error)")
        }
        if nftInfo["nftImageUrl"] != nil {
            nftInfo["type"] = "nft"
        }
        return nftInfo
    }
    
}
