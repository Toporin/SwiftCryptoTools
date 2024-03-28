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
        
        let result = try JSONDecoder().decode(CovalentTokenBalances.self, from: data)
        print("** result: \(String(data: data, encoding: .utf8) ?? "NO-DATA")")
        
        var assetList: [[String:String]] = []

        for item in result.data.items ?? [] {
            var assetData: [String:String] = [:]
            
            assetData["type"] = item.type
            assetData["name"] = item.contractName
            assetData["contract"] = item.contractAddress
            assetData["symbol"] = item.contractTickerSymbol
            assetData["decimals"] = item.contractDecimals.description
            assetData["balance"] = item.balance
            assetData["tokenExplorerLink"] = ""

            assetList.append(assetData)
        }
        print("assetList: \(assetList)")
        return assetList
    }
    
}

// MARK: - CovalentNftsList
struct CovalentNftsList: Codable {
    let data: NftDataClass
    let error: Bool
    let errorMessage, errorCode: JSONNull?

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
    let contractName, contractTickerSymbol, contractAddress: String
    let supportsErc: [String]
    let isSpam: Bool
    let balance, balance24H, type: String
    let floorPriceQuote: Double
    let prettyFloorPriceQuote: String
    let floorPriceNativeQuote: Double
    let nftData: [NftDatum]
    let lastTransferedAt: Date

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
        case lastTransferedAt = "last_transfered_at"
    }
}

// MARK: - NftDatum
struct NftDatum: Codable {
    let tokenID: String
    let tokenURL, originalOwner, currentOwner, externalData: JSONNull?
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
