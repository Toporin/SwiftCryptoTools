//
//  CovalentNFT.swift
//
//
//  Created by Lionel Delvaux on 28/03/2024.
//

import Foundation

public class CovalentNFT: NftExplorer {
    
    func getBasicAuth(with apiKey: String) -> String? {
        let username = apiKey
        let password = ""
        let loginString = "\(username):\(password)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return nil
        }
        let base64LoginString = loginData.base64EncodedString()

        return "Basic \(base64LoginString)"
    }
    
    func getChain(from coinSymbol: String) -> String {
        switch coinSymbol {
        case "MATIC":
            return "matic-mainnet"
        case "MUMBAI":
            return "matic-mumbai"
        default:
            return "matic-mainnet"
        }
    }
    
    public override func getNftOwnerWebLink(addr: String) -> String {
        return ""
    }
        
    public override func getNftWebLink(contract: String, tokenid: String) -> String {
        return ""
    }
    
    @available(iOS 15.0.0, *)
    public override func getNftInfo(contract: String, tokenid: String) async throws -> [String:String] {
        return [:]
    }
    
    @available(iOS 15.0.0, *)
    public override func getNftList(addr: String, contract: String) async throws -> [[String:String]] {
        let apikey: String = self.apiKeys["API_KEY_COVALENT"] ?? ""
        
        guard let url = URL(string: "https://api.covalenthq.com/v1/\(self.getChain(from: self.coinSymbol))/address/\(addr)/balances_nft/") else {
            return []
        }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.setValue(self.getBasicAuth(with: apikey), forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        
        print("** CovalentNFT - Data : \(String(data: data, encoding: .utf8) ?? "NO-DATA")")
        
        var nftList: [[String:String]] = []
        
        do {
            let result = try JSONDecoder().decode(CovalentNftsList.self, from: data)
            for item in result.data.items ?? [] {
                var nftInfo: [String:String] = [:]
                
                nftInfo["nftName"] = item.nftData.first?.externalData?.name ?? "Unknown"
                nftInfo["nftDescription"] = item.nftData.first?.externalData?.description ?? "Unknown"
                nftInfo["nftImageUrl"] = item.nftData.first?.externalData?.image1024 ?? "No image"
                nftInfo["nftExplorerLink"] = item.nftData.first?.tokenURL ?? "No link"
                nftInfo["contract"] = item.contractAddress
                nftInfo["tokenid"] = item.nftData.first?.tokenID
                nftInfo["balance"] = item.balance

                nftList.append(nftInfo)
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }

        print("nftList: \(nftList)")
        return nftList
    }
    
}

// MARK: - CovalentNftsList
struct CovalentNftsList: Codable {
    let data: NftDataClass
    let error: Bool
    let errorMessage, errorCode: NftJSONNull?

    enum CodingKeys: String, CodingKey {
        case data, error
        case errorMessage = "error_message"
        case errorCode = "error_code"
    }
}

// MARK: - DataClass
struct NftDataClass: Codable {
    let updatedAt: String
    let items: [NftItem]
    let address: String

    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case items, address
    }
}

// MARK: - Item
struct NftItem: Codable {
    let contractName, contractTickerSymbol: String?
    let contractAddress: String
    let supportsErc: [SupportsErc]
    let isSpam: Bool
    let balance, balance24H: String
    let type: TypeEnum
    let floorPriceQuote: Double?
    let prettyFloorPriceQuote: String?
    let floorPriceNativeQuote: Double?
    let nftData: [NftDatum]

    enum CodingKeys: String, CodingKey {
        case contractName = "contract_name"
        case contractTickerSymbol = "contract_ticker_symbol"
        case contractAddress = "contract_address"
        case supportsErc = "supports_erc"
        case isSpam = "is_spam"
        case balance
        case balance24H = "balance_24h"
        case type
        case floorPriceQuote = "floor_price_quote"
        case prettyFloorPriceQuote = "pretty_floor_price_quote"
        case floorPriceNativeQuote = "floor_price_native_quote"
        case nftData = "nft_data"
    }
}

// MARK: - NftDatum
struct NftDatum: Codable {
    let tokenID: String
    let tokenURL: String?
    let originalOwner: String?
    let currentOwner: JSONNull?
    let externalData: ExternalData?
    let assetCached, imageCached: Bool

    enum CodingKeys: String, CodingKey {
        case tokenID = "token_id"
        case tokenURL = "token_url"
        case originalOwner = "original_owner"
        case currentOwner = "current_owner"
        case externalData = "external_data"
        case assetCached = "asset_cached"
        case imageCached = "image_cached"
    }
}

// MARK: - ExternalData
struct ExternalData: Codable {
    let name, description: String?
    let assetURL: String?
    let assetFileExtension: String?
    let assetMIMEType: String?
    let assetSizeBytes: String?
    let image: String?
    let image256, image512, image1024: String?
    let animationURL: String?
    let externalURL: String?
    let attributes: [Attribute]

    enum CodingKeys: String, CodingKey {
        case name, description
        case assetURL = "asset_url"
        case assetFileExtension = "asset_file_extension"
        case assetMIMEType = "asset_mime_type"
        case assetSizeBytes = "asset_size_bytes"
        case image
        case image256 = "image_256"
        case image512 = "image_512"
        case image1024 = "image_1024"
        case animationURL = "animation_url"
        case externalURL = "external_url"
        case attributes
    }
}

// MARK: - Attribute
struct Attribute: Codable {
    let traitType: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case traitType = "trait_type"
        case value
    }
}

enum SupportsErc: String, Codable {
    case erc1155 = "erc1155"
    case erc165 = "erc165"
    case erc20 = "erc20"
    case erc721 = "erc721"
}

enum TypeEnum: String, Codable {
    case nft = "nft"
}

// MARK: - Encode/decode helpers

class NftJSONNull: Codable, Hashable {

    public static func == (lhs: NftJSONNull, rhs: NftJSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(NftJSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
