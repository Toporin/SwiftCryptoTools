//
//  Version.swift
//
//
//  Created by Satochip on 04/02/24.
//

import Foundation

// Version
public struct Version {
    // SwiftCryptoTools version based on semver
    // v0.1.0 initial version
    // v0.2.0 add asset listing support for a given address
    // v0.3.0 add Polygon network
    public static let SWIFTCRYPTOTOOLS_MAJOR_VERSION = 0
    public static let SWIFTCRYPTOTOOLS_MINOR_VERSION = 3
    public static let SWIFTCRYPTOTOOLS_REVISION = 0
    public static let SWIFTCRYPTOTOOLS_VERSION = String(SWIFTCRYPTOTOOLS_MAJOR_VERSION) + "." + String(SWIFTCRYPTOTOOLS_MINOR_VERSION) + "." + String(SWIFTCRYPTOTOOLS_REVISION)
}
