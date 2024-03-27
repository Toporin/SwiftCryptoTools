//
//  Covalent.swift
//
//
//  Created by Lionel Delvaux on 25/03/2024.
//

import Foundation

public class Covalent: BlockExplorer {
    
    // main : matic-mainnet
    // test : matic-mumbai
    
    func getBasicAuth(with apiKey: String) -> String {
        let username = apiKey
        let password = ""
        let loginString = "\(username):\(password)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()

        return "Basic \(base64LoginString)"
    }
        
    public override init(coinSymbol: String, apiKeys: [String: String]){
        super.init(coinSymbol: coinSymbol, apiKeys: apiKeys)
        self.url = "https://api.covalenthq.com/v1/"
        self.apiKey = apiKeys
    }
    
    public func getAddressWebLink(addr: String) -> String {
        return "https://www.covalenthq.com/address/\(addr)/"
    }
    
    public func getTokenWebLink(contract: String) -> String {
        return ""
        //preconditionFailure("This method must be overridden")
    }
    
    @available(iOS 15.0.0, *)
    public func getBalance(addr: String) async throws -> Double {
        guard let url = URL(string: "https://api.covalenthq.com/v1/{chainName}/address/\(addr)/balances_native/") else {
            return 0.0
        }
        let apikey: String = self.apiKeys["API_KEY_COVALENT"] ?? ""
        var request = URLRequest(url: url)
        request.headers = ["Content-Type": "application/json"]
        request.httpMethod = "GET"
        request.setValue(self.getBasicAuth(with: apiKey), forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let result = try JSONDecoder().decode(CovalentNativeBalance.self, from: data)
        print("result: \(result)")
        
        return result.items.first?.balance ?? 0.0
    }
    
    // returns detailed list of data about each asset held in a given address
    @available(iOS 15.0.0, *)
    public func getAssetList(addr: String) async throws -> [String:[[String:String]]] {
        //preconditionFailure("This method must be overridden")
        return []
    }
    
    // returns basic list of data about each asset held in a given address
    @available(iOS 15.0.0, *)
    public func getSimpleAssetList(addr: String) async throws -> [[String:String]] {
        // preconditionFailure("This method must be overridden")
        return []
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenBalance(addr: String, contract: String) async throws -> Double {
        // preconditionFailure("This method must be overridden")
        return 10.0
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenInfo(contract: String) async throws -> [String:String] {
        // preconditionFailure("This method must be overridden")
        return []
    }
    
    @available(iOS 15.0.0, *)
    public func getTxInfo(txHash: String, index: Int) async throws -> (script: String, value: UInt64) {
        // preconditionFailure("This method must be overridden")
        return ("", 0)
    }
    
    
    
}

// MARK: - CovalentNativeBalance
struct CovalentNativeBalance: Codable {
    let address, updatedAt, quoteCurrency: String
    let chainID: Int
    let chainName: String
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case address
        case updatedAt = "updated_at"
        case quoteCurrency = "quote_currency"
        case chainID = "chain_id"
        case chainName = "chain_name"
        case items
    }
}

// MARK: - Item
struct Item: Codable {
    let contractDecimals: Int
    let contractName, contractTickerSymbol, contractAddress: String
    let supportsErc: [String]
    let logoURL: String
    let blockHeight: Int
    let balance: String
    let quoteRate, quote: Double
    let prettyQuote: String

    enum CodingKeys: String, CodingKey {
        case contractDecimals = "contract_decimals"
        case contractName = "contract_name"
        case contractTickerSymbol = "contract_ticker_symbol"
        case contractAddress = "contract_address"
        case supportsErc = "supports_erc"
        case logoURL = "logo_url"
        case blockHeight = "block_height"
        case balance
        case quoteRate = "quote_rate"
        case quote
        case prettyQuote = "pretty_quote"
    }
}

// MARK: - CovalentTokenBalances
struct CovalentTokenBalances: Codable {
    let address, updatedAt, nextUpdateAt, quoteCurrency: String
    let chainID: Int
    let chainName: String
    let items: [Item]
    let pagination: JSONNull?

    enum CodingKeys: String, CodingKey {
        case address
        case updatedAt = "updated_at"
        case nextUpdateAt = "next_update_at"
        case quoteCurrency = "quote_currency"
        case chainID = "chain_id"
        case chainName = "chain_name"
        case items, pagination
    }
}

// MARK: - Item
struct Item: Codable {
    let contractDecimals: Int?
    let contractName, contractTickerSymbol: String?
    let contractAddress: String
    let supportsErc: [SupportsErc]
    let logoURL: String
    let contractDisplayName: String?
    let logoUrls: LogoUrls
    let lastTransferredAt: Date
    let nativeToken: Bool
    let type: TypeEnum
    let isSpam: Bool
    let balance, balance24H: String
    let quoteRate, quoteRate24H, quote: Double?
    let prettyQuote: String?
    let quote24H: Double?
    let prettyQuote24H: String?
    let protocolMetadata, nftData: JSONNull?

    enum CodingKeys: String, CodingKey {
        case contractDecimals = "contract_decimals"
        case contractName = "contract_name"
        case contractTickerSymbol = "contract_ticker_symbol"
        case contractAddress = "contract_address"
        case supportsErc = "supports_erc"
        case logoURL = "logo_url"
        case contractDisplayName = "contract_display_name"
        case logoUrls = "logo_urls"
        case lastTransferredAt = "last_transferred_at"
        case nativeToken = "native_token"
        case type
        case isSpam = "is_spam"
        case balance
        case balance24H = "balance_24h"
        case quoteRate = "quote_rate"
        case quoteRate24H = "quote_rate_24h"
        case quote
        case prettyQuote = "pretty_quote"
        case quote24H = "quote_24h"
        case prettyQuote24H = "pretty_quote_24h"
        case protocolMetadata = "protocol_metadata"
        case nftData = "nft_data"
    }
}

// MARK: - LogoUrls
struct LogoUrls: Codable {
    let tokenLogoURL: String
    let protocolLogoURL: JSONNull?
    let chainLogoURL: String

    enum CodingKeys: String, CodingKey {
        case tokenLogoURL = "token_logo_url"
        case protocolLogoURL = "protocol_logo_url"
        case chainLogoURL = "chain_logo_url"
    }
}

enum SupportsErc: String, Codable {
    case erc20 = "erc20"
}

enum TypeEnum: String, Codable {
    case cryptocurrency = "cryptocurrency"
    case dust = "dust"
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
