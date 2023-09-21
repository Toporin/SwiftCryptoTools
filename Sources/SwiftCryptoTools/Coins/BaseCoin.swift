import Foundation

public enum CoinError: Error {
    case WrongPubkeySize(length: Int, expected: Int)
    case UnsupportedCoinError
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
    //let supportSegwit: Bool = true
    //let magicbyte: UInt32 = 0
    //let scriptMagicbyte: UInt32 = 0
    //let segwitHrp: String = ""
    
    public var supportToken: Bool = false
    public var supportNft: Bool = false
    public var blockExplorer: BlockExplorer? = nil
    public var nftExplorer: NftExplorer? = nil
    public var priceExplorer: PriceExplorer? = nil
    public var apiKeys: [String: String] = [:]

    public var isTestnet: Bool
    public var useCompressedAddr: Bool = true
    public var wifPrefix: UInt8 = 0
    //let int hd_path
    //public Map<String, Integer> wif_script_types;
    //public Map<String, Integer> xprv_headers;
    //public Map<String, Integer> xpub_headers;
    
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
    
    public func contractBytesToString(contractBytes: [UInt8]) -> String {
        //preconditionFailure("This method must be overridden")
        return ""
    }
    
    public class func contractStringToBytes(contractString: String) throws -> [UInt8] {
        // valid by default
        return [UInt8]()
    }
    
    public func tokenidBytesToString(tokenidBytes: [UInt8]) -> String {
        //preconditionFailure("This method must be overridden")
        return ""
    }
    
    public class func tokenidStringToBytes(tokenidString: String) throws -> [UInt8] {
        // valid by default
        return [UInt8]()
    }
    
    //**********************************************
    //*          BLOCK EXPLORER METHODS            *
    //**********************************************
    
    @available(iOS 15.0.0, *)
    public func getBalance(addr: String) async throws -> Double {
        if let balance = try await blockExplorer?.getBalance(addr: addr){
            print ("balance: \(balance)")
            return balance
        } else {
            throw CoinError.FailedToGetBalance
        }
    }
    
    @available(iOS 15.0.0, *)
    public func getAssetList(addr: String) async throws -> [String : [[String : String]]] {
        if let assetList = try await blockExplorer?.getAssetList(addr: addr){
            return assetList
        } else {
            //throw CoinError.FailedToGetAssetList
            var assetList: [String:[[String:String]]] = [:]
            return assetList
        }
    }
    
    @available(iOS 15.0.0, *)
    public func getSimpleAssetList(addr: String) async -> [[String:String]] {
        do{
            if let assetList = try await blockExplorer?.getSimpleAssetList(addr: addr){
                return assetList
            } else {
                let assetList: [[String:String]] = []
                return assetList
            }
        } catch {
            print("getSimpleAssetList error: \(error)")
            let assetList: [[String:String]] = []
            return assetList
        }
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenBalance(addr: String, contract: String) async throws -> Double {
        if let balance = try await blockExplorer?.getTokenBalance(addr: addr, contract: contract){
            print ("tokenBalance: \(balance)")
            return balance
        } else {
            throw CoinError.FailedToGetTokenBalance
        }
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenInfo(contract: String) async throws -> [String:String] {
        if let tokenInfo = try await blockExplorer?.getTokenInfo(contract: contract){
            print ("tokenInfo: \(tokenInfo)")
            return tokenInfo
        } else {
            throw CoinError.FailedToGetTokenInfo
        }
    }
    
    public func getAddressWebLink(address: String) -> String? {
        return blockExplorer?.getAddressWebLink(addr: address)
    }
    
    public func getTokenWebLink(contract: String) -> String? {
        if !self.supportToken {
            return nil
        } else {
            return blockExplorer?.getTokenWebLink(contract: contract)
        }
    }
    
    //**********************************************
    //*            NFT EXPLORER METHODS            *
    //**********************************************
    
    public func getNftOwnerWebLink(addr: String) -> String {
        if let url = nftExplorer?.getNftOwnerWebLink(addr: addr){
            print ("url: \(url)")
            return url
        } else {
            return "https://notfound.org/en/notfound"
        }
    }
    
    public func getNftWebLink(contract: String, tokenid: String) -> String {
        if let url = nftExplorer?.getNftWebLink(contract: contract, tokenid: tokenid){
            print ("url: \(url)")
            return url
        } else {
            return "https://notfound.org/en/notfound"
        }
    }
    
    @available(iOS 15.0.0, *)
    public func getNftInfo(contract: String, tokenid: String) async throws -> [String:String] {
        if let nftInfo = try await nftExplorer?.getNftInfo(contract: contract, tokenid: tokenid){
            print ("nftInfo: \(nftInfo)")
            return nftInfo
        } else {
            throw CoinError.FailedToGetNftInfo
        }
    }
    
    //debug
    @available(iOS 15.0.0, *)
    public func getNftList(addr: String, contract: String) async -> [[String:String]] {
        do {
            if let nftList = try await nftExplorer?.getNftList(addr: addr, contract: contract){
                print ("nftList: \(nftList)")
                return nftList
            } else {
                print("getNftList: no NFT explorer available for \(self.displayName)")
                let nftList: [[String:String]] = []
                return nftList
            }
        } catch {
            print("getNftList error: \(error)")
            let nftList: [[String:String]] = []
            return nftList
        }
    }
    
    //**********************************************
    //*          PRICE EXPLORER METHODS            *
    //**********************************************
    
    @available(iOS 15.0.0, *)
    public func getExchangeRateBetween(otherCoin: String) async throws -> Double {
        if let rate = try await priceExplorer?.getExchangeRateBetween(otherCoin: otherCoin) {
            print ("rate: \(rate)")
            return rate
        } else {
            throw CoinError.FailedToGetExchangeRate
        }
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenExchangeRateBetween(contract: String, otherCoin: String) async throws -> Double {
        if let rate = try await priceExplorer?.getTokenExchangeRateBetween(contract: contract, otherCoin: otherCoin) {
            print ("rate: \(rate)")
            return rate
        } else {
            throw CoinError.FailedToGetTokenExchangeRate
        }
    }
}
