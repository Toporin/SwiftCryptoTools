import Foundation

public enum CoinError: Error {
    case WrongPubkeySize(length: Int, expected: Int)
    case FailedToGetBalance
    case FailedToGetTokenBalance
    case FailedToGetTokenInfo
    case FailedToGetNftInfo
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
    //var priceExplorer: PriceExplorer = nil
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
    
    public func tokenidBytesToString(tokenidBytes: [UInt8]) -> String {
        //preconditionFailure("This method must be overridden")
        return ""
    }
    
    //**********************************************
    //*          BLOCK EXPLORER METHODS            *
    //**********************************************
    
//    public func getBalance(addr: String) throws -> Double {
//        preconditionFailure("This method must be overridden")
//    }
    
    @available(iOS 15.0.0, *)
    public func getBalance(addr: String) async throws -> Double {
        //preconditionFailure("This method must be overridden")
        do {
//            let balance = try await blockExplorer?.getBalance(addr: addr)
//            print ("balance: \(balance)")
//            return balance
            if let balance = try await blockExplorer?.getBalance(addr: addr){
                print ("balance: \(balance)")
                return balance
            } else {
                throw CoinError.FailedToGetBalance
            }
        } catch {
            throw CoinError.FailedToGetBalance
        }
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenBalance(addr: String, contract: String) async throws -> Double {

        do {
            if let balance = try await blockExplorer?.getTokenBalance(addr: addr, contract: contract){
                print ("tokenBalance: \(balance)")
                return balance
            } else {
                throw CoinError.FailedToGetTokenBalance
            }
        } catch {
            throw CoinError.FailedToGetTokenBalance
        }
    }
    
    @available(iOS 15.0.0, *)
    public func getTokenInfo(contract: String) async throws -> [String:String] {

        do {
            if let tokenInfo = try await blockExplorer?.getTokenInfo(contract: contract){
                print ("tokenInfo: \(tokenInfo)")
                return tokenInfo
            } else {
                throw CoinError.FailedToGetTokenInfo
            }
        } catch {
            throw CoinError.FailedToGetTokenInfo
        }
    }
    
    //**********************************************
    //*            NFT EXPLORER METHODS            *
    //**********************************************
    
    public func getNftOwnerWeburl(addr: String) -> String {
        if let url = nftExplorer?.getNftOwnerWeburl(addr: addr){
            print ("url: \(url)")
            return url
        } else {
            return "https://notfound.org/en/notfound"
        }
    }
    
    public func getNftWeburl(contract: String, tokenid: String) -> String {
        if let url = nftExplorer?.getNftWeburl(contract: contract, tokenid: tokenid){
            print ("url: \(url)")
            return url
        } else {
            return "https://notfound.org/en/notfound"
        }
    }
    
    @available(iOS 15.0.0, *)
    public func getNftInfo(contract: String, tokenid: String) async throws -> [String:String] {
        do {
            if let nftInfo = try await nftExplorer?.getNftInfo(contract: contract, tokenid: tokenid){
                print ("nftInfo: \(nftInfo)")
                return nftInfo
            } else {
                throw CoinError.FailedToGetNftInfo
            }
        } catch {
            throw CoinError.FailedToGetNftInfo
        }
    }
    
    //**********************************************
    //*          PRICE EXPLORER METHODS            *
    //**********************************************
}
