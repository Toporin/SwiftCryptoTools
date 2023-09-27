import Foundation
import BigInt

public class Counterparty: Bitcoin {
    
    public var priceExplorer2: PriceExplorer? = nil
    
    public override init(isTestnet: Bool, apiKeys: [String: String]){
        super.init(isTestnet: isTestnet, apiKeys: apiKeys)
        
        supportSegwit = false
        
        if self.isTestnet {
            coinSymbol = "XCPTEST"
            displayName = "Counterparty Testnet"
            slip44 = 0x00000009
        } else {
            coinSymbol = "XCP"
            displayName = "Counterparty"
            slip44 = 0x80000009
            //wifPrefix = 0xb0 // use same as bitcoin
        }
        
        supportNft = true
        supportToken = true
        blockExplorer = XchainBlockExplorer(coinSymbol: self.coinSymbol, apiKeys: apiKeys)
        nftExplorer = XchainNftExplorer(coinSymbol: self.coinSymbol, apiKeys: apiKeys)
        priceExplorer = Coingecko(coinSymbol: coinSymbol, isTestnet: isTestnet, apiKeys: apiKeys)
        
        // backup
        priceExplorer2 = Coingate(coinSymbol: coinSymbol, isTestnet: isTestnet, apiKeys: apiKeys)
    }
    
    @available(iOS 15.0.0, *)
    public override func getExchangeRateBetween(coin: String, otherCoin: String) async -> Double? {
        // coingate and coingecko support different coin pairs...
        if let rate = try? await priceExplorer?.getExchangeRateBetween(coin: coin, otherCoin: otherCoin) {
            return rate
        } else {
            print("Counterparty getExchangeRateBetween error: no priceExplorer available")
            if let rate = try? await priceExplorer2?.getExchangeRateBetween(coin: coin, otherCoin: otherCoin) {
                return rate
            } else {
                print("Counterparty getExchangeRateBetween error: no priceExplorer2 available")
                return nil
            }
        }
    }
    
    // deprecated
    public override func contractBytesToString(contractBytes: [UInt8]) -> String {
        if let contractString = String(bytes: contractBytes, encoding: .utf8) {
            print("contractString: \(contractString)")
            return contractString
        } else {
            print("not a valid UTF-8 sequence")
            return ""
        }
    }
    
    public class override func contractStringToBytes(contractString: String) throws -> [UInt8] {
        // contract cannot start, end with '.' or contains consecutive dots
        //https://stackoverflow.com/questions/40718851/regex-that-does-not-allow-consecutive-dots
        var asset = contractString
        var subasset = ""
        
        // check subasset if any
        if asset.contains(".") {
            if asset.contains(".."){
                throw ContractParsingError.XcpAssetFormatError
            }
            let parts = asset.split(separator: ".", maxSplits: 1)
            asset = String(parts[0])
            if parts.count>=2 {
                subasset = String(parts[1])
                let minlength = String(1)
                let maxlength = String(250 - asset.count - 1)
                let pattern = #"^[a-zA-Z0-9.-_@!]{"# + minlength + #","# + maxlength + #"}$"#
                if !subasset.matches(pattern: pattern) {
                    print("subasset \(subasset) does not match regex!")
                    throw ContractParsingError.XcpSubassetFormatError
                } else {
                    print("subasset \(subasset) matches regex!")
                }
            }
        }
        if (asset.hasPrefix("A") || asset.hasPrefix("a")){
            // numeric asset
            asset = asset.uppercased() // a=>A
            let assetNbr = String(asset.dropFirst(1))
            let pattern = #"^\d+$"#
            if !assetNbr.matches(pattern: pattern) {
                throw ContractParsingError.DecimalFormatError
            }
            let biguint: BigUInt = BigUInt(stringLiteral: assetNbr)
            let minBound = BigUInt(26).power(12) + BigUInt(1)
            let maxBound = BigUInt(256).power(8)
            if (biguint<minBound) || (biguint>maxBound) {
                throw ContractParsingError.XcpNumericAssetOutOfBound
            }
        } else {
            // named asset
            asset = asset.uppercased()
            let pattern = #"^[A-Z]{4,12}$"#
            if !asset.matches(pattern: pattern) {
                print("asset \(asset) does not match regex!")
                throw ContractParsingError.XcpAssetFormatError
            } else {
                print("asset \(asset) matches regex!")
            }
        }
        // encode
        let contract: String
        if subasset == "" {
            contract = asset
        }else {
            contract = asset + "." + subasset
        }
        let contractBytes = Array(contract.utf8)
        if contractBytes.count>32 {
            throw ContractParsingError.TooLongError
        }
        return contractBytes
    }
    
    public override func tokenidBytesToString(tokenidBytes: [UInt8]) -> String {
        // Counterparty does not use tokenid
        // could be used to store an additional message?
        if let tokenidString = String(bytes: tokenidBytes, encoding: .utf8) {
            print("tokenidString: \(tokenidString)")
            return tokenidString
        } else {
            print("not a valid UTF-8 sequence")
            return ""
        }
    }
    
    public class override func tokenidStringToBytes(tokenidString: String) throws -> [UInt8]{
        // XCP does not use tokenid
        let tokenidBytes = Array(tokenidString.utf8)
        if tokenidBytes.count>32 {
            throw ContractParsingError.TooLongError
        }
        return tokenidBytes
    }
}
