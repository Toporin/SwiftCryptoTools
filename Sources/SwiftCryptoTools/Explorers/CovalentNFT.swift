//
//  CovalentNFT.swift
//
//
//  Created by Lionel Delvaux on 28/03/2024.
//

import Foundation

public class CovalentNFT: NftExplorer {
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
        return []
    }
    
}
