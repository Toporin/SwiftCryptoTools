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
        
        //No-cache flag : ?with-uncached=true
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
                let nftInfo = self.getAllNftsData(from: item.nftData, for: item.contractAddress)
                nftList.append(contentsOf: nftInfo)
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
        
        print("nftList: \(nftList)")
        return nftList
    }
    
    private func getAllNftsData(from data: [NftDatum], for contract: String) -> [[String:String]] {
        var nftData: [[String:String]] = []
        
        for item in data {
            var nftInfo: [String:String] = [:]
            
            nftInfo["name"] = item.externalData?.name ?? "Unknown"
            nftInfo["nftDescription"] = item.externalData?.description ?? "Unknown"
            nftInfo["nftImageUrl"] = item.externalData?.image1024 ?? "No image"
            nftInfo["nftExplorerLink"] = "https://polygonscan.com/nft/\(contract)/\(item.tokenID)"
            nftInfo["tokenid"] = item.tokenID
            nftInfo["contract"] = contract
            nftInfo["balance"] = "1"
            
            nftData.append(nftInfo)
        }
        
        nftData = Array(Set(nftData))
        return nftData
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
    let balance: String?
    let nftData: [NftDatum]

    enum CodingKeys: String, CodingKey {
        case contractName = "contract_name"
        case contractTickerSymbol = "contract_ticker_symbol"
        case contractAddress = "contract_address"
        case balance
        case nftData = "nft_data"
    }
}

// MARK: - NftDatum
struct NftDatum: Codable {
    let tokenID: String
    let tokenURL: String?
    let externalData: ExternalData?
    

    enum CodingKeys: String, CodingKey {
        case tokenID = "token_id"
        case tokenURL = "token_url"
        case externalData = "external_data"
    }
}

// MARK: - ExternalData
struct ExternalData: Codable {
    let name, description: String?
    let assetURL: String?
    let image1024: String?

    enum CodingKeys: String, CodingKey {
        case name, description
        case assetURL = "asset_url"
        case image1024 = "image_1024"
    }
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
