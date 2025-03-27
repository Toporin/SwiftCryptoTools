import Foundation

public enum CoinError: Error {
    case WrongPubkeySize(length: Int, expected: Int)
    case UnsupportedCoinError
    case FailedToGetCoinInfo
    case FailedToGetBalance
    case FailedToGetAssetList
    case FailedToGetTokenBalance
    case FailedToGetTokenInfo
    case FailedToGetNftInfo
    case FailedToGetExchangeRate
    case FailedToGetTokenExchangeRate
}

public enum ContractParsingError: Error {
    case HexFormatError
    case TooLongError
    case TooShortError
    case DecimalFormatError
    case XcpSubassetFormatError
    case XcpNumericAssetOutOfBound
    case XcpAssetFormatError
}

public class BaseCoin {
    
    public var coinSymbol: String = "BaseCoin"
    public var displayName: String = "BaseCoin"
    public var slip44: UInt32 = 0x0
    
    public var supportToken: Bool = false
    public var supportNft: Bool = false
    
    public var apiKeys: [String: String] = [:]
    public var explorers: [BlockchainExplorer] = []
    public var priceExplorers: [PriceExplorer] = []
    
    // todo deprecate
//    public var blockExplorer: BlockExplorer? = nil
//    public var nftExplorer: NftExplorer? = nil
//    public var priceExplorer: PriceExplorer? = nil
    
    public var isTestnet: Bool
    public var useCompressedAddr: Bool = true
    public var wifPrefix: UInt8 = 0
    
    public init(isTestnet: Bool, apiKeys: [String: String]){
        self.isTestnet = isTestnet
        self.apiKeys = apiKeys
        
        if isTestnet {
            wifPrefix = 0xef
        } else {
            wifPrefix = 0x80
        }
        
    }
    
    //****************************************
    //*          ENCODING METHODS            *
    //****************************************
    
    public func encodePrivkey(privkey: [UInt8]) -> String {
        //Preconditions.checkArgument(privkey.length == 32, "Private keys must be 32 bytes");
        let bytes: [UInt8]
        if useCompressedAddr { //"wif_compressed"
            // Keys that have compressed public components have an extra 1 byte on the end in dumped form.
            bytes = privkey + [1]
        } else { // "wif"
            bytes = privkey
        }
        return Base58.encodeChecked(version: wifPrefix, payload: bytes)
    }
    
    public func pubToAddress(pubkey: [UInt8]) throws -> String {
        preconditionFailure("This method must be overridden")
    }
    
    public func keyBytesToString(keyBytes: [UInt8]) -> String {
        return "0x" + keyBytes.toHexString()
    }
    
    //**********************************************
    //*          BLOCK EXPLORER METHODS            *
    //**********************************************
    
    public func getAddressWebLink(addr: String) -> String? {
//        for explorer in explorers {
//            let link = explorer.getAddressWebLink(addr: addr)
//            return link
//        }
        let link = explorers[0].getAddressWebLink(addr: addr)
        return link
    }
    
    @available(iOS 15.0.0, *)
    public func getCoinInfo(addr: String) async throws -> [String : String] {
        for explorer in explorers {
            do {
                let coinInfo = try await explorer.getCoinInfo(addr: addr)
                return coinInfo
            } catch {
                print("failed to fetch coininfo from: \(explorer) with error: \(error)")
            }
        }
        throw CoinError.FailedToGetCoinInfo
    }
    
    @available(iOS 15.0.0, *)
    public func getAssetList(addr: String) async throws -> [[String : String]] {
        for explorer in explorers {
            do {
                let assetList = try await explorer.getAssetList(addr: addr)
                return assetList
            } catch {
                print("failed to fetch assetList from: \(explorer)")
            }
        }
        throw CoinError.FailedToGetAssetList
    }
    
    //**********************************************
    //*          PRICE EXPLORER METHODS            *
    //**********************************************
    
    @available(iOS 15.0.0, *)
    public func getExchangeRateWith(otherCoin: String) async throws -> Double? { // todo rename getExchangeRateWith
        for explorer in priceExplorers {
            do {
                let rate = try await explorer.getExchangeRateWith(otherCoin: otherCoin)
                return rate
            } catch {
                print("failed to fetch price from: \(explorer)")
            }
        }
        return nil
    }
    
    @available(iOS 15.0.0, *)
    public func getExchangeRateBetween(coin: String, otherCoin: String) async -> Double? {
        for explorer in priceExplorers {
            do {
                let rate = try await explorer.getExchangeRateBetween(coin: coin, otherCoin: otherCoin)
                return rate
            } catch {
                print("failed to fetch price from: \(explorer) error: \(error)")
            }
        }
        return nil
    }
    
}
