import Foundation

public class Blockstream: BlockExplorer {
    
    struct ChainStats: Codable {
        let fundedTxoSum: Int64
        let spentTxoSum: Int64
        enum CodingKeys: String, CodingKey {
            case fundedTxoSum = "funded_txo_sum", spentTxoSum = "spent_txo_sum"
        }
    }

    struct JsonResponseBalance: Codable {
        let address: String
        let chainStats: ChainStats
        enum CodingKeys: String, CodingKey {
            case address, chainStats = "chain_stats"
        }
    }
    
    public func getUrl() -> String {
        if self.coinSymbol == "BTC" {
            return "https://blockstream.info/api/"
        } else {
            return "https://blockstream.info/testnet/api/"
        }
    }
    
    public override func getAddressWebLink(addr: String) -> String {
        if self.coinSymbol == "BTC" {
            return "https://blockstream.info/address/"+addr
        } else {
            return "https://blockstream.info/testnet/address/"+addr
        }
    }
    
    /// Make network request using async `URLSession` API
    @available(iOS 15.0, *)
    public override func getBalance(addr: String) async throws -> Double {
        print("In Blockstream getBalance for: \(addr)")
        
        // https://blockstream.info/api/address/ + addr
        let urlString: String = self.getUrl() + "address/" + addr
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        print("data: \(data)")
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseBalance.self, from: data)
        print("result: \(result)")
        
        let fundedTxoSum: Int64 = result.chainStats.fundedTxoSum
        let spentTxoSum: Int64 = result.chainStats.spentTxoSum
        let balance: Double = Double(fundedTxoSum-spentTxoSum)/Double(100_000_000)
        return balance
    }

//    {"txid":"667ba3ad5d55a609e48fb9eb91adf501891ce25b78dc9b253fe8813cc86cd029","version":2,"locktime":2431023,"vin":[{"txid":"8bb6f31589c93e228dfaeecf5c50d1258aaa82c26b493c7e2cef293bdf8b6c95","vout":1,"prevout":{"scriptpubkey":"00142835fdeb06149bc0c01c65f789ae7526cc4faf51","scriptpubkey_asm":"OP_0 OP_PUSHBYTES_20 2835fdeb06149bc0c01c65f789ae7526cc4faf51","scriptpubkey_type":"v0_p2wpkh","scriptpubkey_address":"tb1q9q6lm6cxzjdupsquvhmcntn4ymxylt63we8e00","value":249998900},"scriptsig":"","scriptsig_asm":"","witness":["3044022040992707014e4023bb75cc7da93cd81d6b336c569b4dd35fd5d457aa6d6c90d3022032f8583f3d89226df2e576c31cb996f2340844fd5c82d5aee5fd7f1df60d471701","03dbadd193076ba39a94bacf3721e0f9ac7b07fb0be7fce46357bf29c169404f23"],"is_coinbase":false,"sequence":4294967293}],"vout":[{"scriptpubkey":"76a91460910a50647806bd2f06189b84f7696e613614f888ac","scriptpubkey_asm":"OP_DUP OP_HASH160 OP_PUSHBYTES_20 60910a50647806bd2f06189b84f7696e613614f8 OP_EQUALVERIFY OP_CHECKSIG","scriptpubkey_type":"p2pkh","scriptpubkey_address":"mpKYv3c1UMCd1kig4oLAynx17tpJF3MDQK","value":100000000},{"scriptpubkey":"0014f433682fda86ed139f3b93a8efed6a7cbb48e586","scriptpubkey_asm":"OP_0 OP_PUSHBYTES_20 f433682fda86ed139f3b93a8efed6a7cbb48e586","scriptpubkey_type":"v0_p2wpkh","scriptpubkey_address":"tb1q7sekst76smk388emjw5wlmt20ja53evxxvy7rc","value":149998600}],"size":225,"weight":573,"fee":300,"status":{"confirmed":true,"block_height":2431024,"block_hash":"0000000017db674b3bc936ffc416ce997e2c525c0b61198957fd984e24bfe7ff","block_time":1682428574}}

    public struct Vout: Codable {
        let scriptpubkey: String
        //let scriptpubkey_asm: String
        //let scriptpubkey_type: String
        //let scriptpubkey_address: String
        let value: UInt64
    }
    
    public struct JsonResponseTx: Codable {
        let txid: String
        let version: Int
        let locktime: UInt64
        let size: Int
        let weight: Int
        let fee: Int
        //let vins: [Vin]
        let vout: [Vout]
        //let status: Status
        enum CodingKeys: String, CodingKey {
            case txid, version, locktime, size, weight, fee, vout
        }
    }
    
    @available(iOS 15.0, *)
    public override func getTxInfo(txHash: String, index: Int) async throws -> (script: String, value: UInt64) {
        print("In Blockstream getTx for: txhash \(txHash)")
        
        // https://blockstream.info/api/tx/ + txHash
        let urlString: String = self.getUrl() + "tx/" + txHash
        print("urlString: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw DataFetcherError.invalidURL
        }

        // Use the async variant of URLSession to fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        print("data: \(data)")
        
        // Parse the JSON data
        let result = try JSONDecoder().decode(JsonResponseTx.self, from: data)
        print("result: \(result)")
        
        let vouts = result.vout
        let vout = vouts[index]
        let script = vout.scriptpubkey
        let value = vout.value
        return (script, value)
    }
    
    
}
