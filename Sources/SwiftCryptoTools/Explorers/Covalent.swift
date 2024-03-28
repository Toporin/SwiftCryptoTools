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
    
    func convertBalanceToDouble(balance: String, decimals: Int) -> Double? {
        guard let balanceDecimal = Decimal(string: balance) else {
            print("Error: Balance is not a valid number.")
            return nil
        }
        
        let divisor = Decimal(sign: .plus, exponent: -decimals, significand: 1)
        let balanceDouble = (balanceDecimal * divisor) as NSDecimalNumber
        return balanceDouble.doubleValue
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
        
    public override init(coinSymbol: String, apiKeys: [String: String]){
        super.init(coinSymbol: coinSymbol, apiKeys: apiKeys)
    }
    
    public override func getAddressWebLink(addr: String) -> String {
        return "https://www.covalenthq.com/address/\(addr)/"
    }
    
    public override func getTokenWebLink(contract: String) -> String {
        return ""
    }
    
    @available(iOS 15.0.0, *)
    public override func getBalance(addr: String) async throws -> Double {
        guard let url = URL(string: "https://api.covalenthq.com/v1/\(self.getChain(from: self.coinSymbol))/address/\(addr)/balances_native/") else {
            return 0.0
        }
        let apikey: String = self.apiKeys["API_KEY_COVALENT"] ?? ""
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.setValue(self.getBasicAuth(with: apikey), forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let result = try JSONDecoder().decode(CovalentNativeBalance.self, from: data)
        print("** result: \(String(data: data, encoding: .utf8) ?? "NO-DATA")")
        
        // convert result.items.first?.balance to Double
        guard let balanceText = result.data.items.first?.balance,
              let decimals = result.data.items.first?.contractDecimals,
              let balanceResult = self.convertBalanceToDouble(balance: balanceText, decimals: decimals) else {
            return 0.0
        }
        
        print("** Fromatted balance : \(balanceResult)")
        
        return balanceResult
    }
    
    // returns detailed list of data about each asset held in a given address
    @available(iOS 15.0.0, *)
    public override func getAssetList(addr: String) async throws -> [String:[[String:String]]] {
        //preconditionFailure("This method must be overridden")
        return [:]
    }
    
    // returns basic list of data about each asset held in a given address
    @available(iOS 15.0.0, *)
    public override func getSimpleAssetList(addr: String) async throws -> [[String:String]] {
        print("in Covalent getSimpleAssetList - addr: \(addr)")
        
        let apikey: String = self.apiKeys["API_KEY_COVALENT"] ?? ""
        
        guard let url = URL(string: "https://api.covalenthq.com/v1/\(self.getChain(from: self.coinSymbol))/address/\(addr)/balances_v2/") else {
            return []
        }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.setValue(self.getBasicAuth(with: apikey), forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        print("** result: \(String(data: data, encoding: .utf8) ?? "NO-DATA")")
        
        let result = try JSONDecoder().decode(CovalentTokenBalances.self, from: data)
        
        var assetList: [[String:String]] = []

        for item in result.data.items ?? [] {
            var assetData: [String:String] = [:]
            
            assetData["type"] = "token"
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
    
    @available(iOS 15.0.0, *)
    public override func getTokenBalance(addr: String, contract: String) async throws -> Double {
        return 0.0
    }
    
    @available(iOS 15.0.0, *)
    public override func getTokenInfo(contract: String) async throws -> [String:String] {
        return [:]
    }
    
    @available(iOS 15.0.0, *)
    public override func getTxInfo(txHash: String, index: Int) async throws -> (script: String, value: UInt64) {
        return ("", 0)
    }

}

// MARK: - CovalentNativeBalance
struct CovalentNativeBalance: Codable {
    let data: DataClass
    let error: Bool
    let errorMessage, errorCode: JSONNull?

    enum CodingKeys: String, CodingKey {
        case data, error
        case errorMessage = "error_message"
        case errorCode = "error_code"
    }
}

// MARK: - DataClass
struct DataClass: Codable {
    let address, updatedAt, quoteCurrency: String
    let chainID: Int
    let chainName: String
    let items: [NativeItem]

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
struct NativeItem: Codable {
    let contractDecimals: Int
    let contractName, contractTickerSymbol, contractAddress: String
    let supportsErc: [String]
    let logoURL: String
    let blockHeight: Int
    let balance: String
    let quoteRate, quote: Double?
    let prettyQuote: String?

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
    let data: TokenDataClass
    let error: Bool
    let errorMessage, errorCode: JSONNull?

    enum CodingKeys: String, CodingKey {
        case data, error
        case errorMessage = "error_message"
        case errorCode = "error_code"
    }
}

// MARK: - DataClass
struct TokenDataClass: Codable {
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
    let contractDecimals: Int
    let contractName, contractTickerSymbol, contractAddress: String
    let supportsErc: [String]
    let logoURL: String
    let contractDisplayName: String
    let logoUrls: LogoUrls
    let nativeToken: Bool
    let type: String
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
