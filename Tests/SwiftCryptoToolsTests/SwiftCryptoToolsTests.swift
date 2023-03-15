import XCTest
import secp256k1

@testable import SwiftCryptoTools

// test functions specifically used by SatodimeTool
// test vectors made with https://iancoleman.io/bip39/
// seed: tonight stem cause eyebrow estate smart duck wrong toe under job danger
// path: m/84'/0'/0'/0/* (using BIP84 path to get bech32 and base58 address)

// Run test with:
//xcodebuild test -scheme SwiftCryptoTools -destination 'platform=iOS Simulator,OS=16.1,name=iPhone 14'
// show destinations available with -showdestinations
final class SwiftCryptoToolsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftCryptoTools().text, "Hello, World!")
    }
    
    /* BTC */
    func testBtc() throws {
        
        let PUBKEY_BTC = [
            "03b7b3957daedecee4488dcb0b8cf3f3372d64d5c559953d2a2539f55e6474c8ce",
            "03e5c1e865d21a239c6639e75586df1f0a5e59853694601e78dccb22481fad08c0",
            "03f21a3b7ff93a4396d886b04b045b8a4dfaa3e13ae169adf36a7390f65af964c0",
            "035f6cb6545543c6b69ba402e19362a71c9ff58a93f8c2d812e0a6c27c6304e5d2",
            "03e1d8b41fa14419293b29ad6f98d5bd1827ae21b5f1083a7cc001955db2ee628c",
        ]
        
        let ADDRESS_LEGACY_BTC = [
            "1Q6QXhpreAW8wDRwaL6jvdEcbbceFMw2mv",
            "1976pT5yu88hDa7HsQK76tpbyYtPTyN3cF",
            "1QC6JNGbXdmQFkBp69yFFXdYZKvXtfCeEx",
            "14Kz6dHFJjJNqj2hvQ84vSzYq78T9pmoWi",
            "1Lr8JCa936osnV288Jm3LYBKKvvvQJkdfy",
        ]
        
        let ADDRESS_SEGWIT_BTC = [
            "bc1ql4gf6wjve0enmmsvr0vrv4f0v9cnxzcnhpjnx2",
            "bc1qtr59h4kqargu5les2as8w2tumqreh58ew2ks5d",
            "bc1qle37gu93ja9csxndeu7q57g49jf5j4qsckw9g0",
            "bc1qy3lcdhn4crpev6ppejlt20kzhdg528f3t4wp27",
            "bc1qmx6deexe6r8vvn775e5hjur78g2q4n5fe0fzyn",
        ]
        
        let PRIVKEY_WIF_BTC = [
            "KzsYHPmjK3VbtFvRL4PbaEAnUePcgQjJZC1B4RjcR1AXbZbC5Yfu",
            "L4cWMhJWvJwBFv1WrwfoTZYW4EDrT33KSoYtQEfnruzgNiupUNnq",
            "L4wZXSWJNr2fWbmf2Pfh1XyFew9tSog65nxUiA6767fhot4kGBeX",
            "L1Xb8kjGUgT322K2pGpUV3EYzzUucT9hsR34mAphtY1C8RwVqLWP",
            "KxF9SWjzRygz8DP32RdPhak19aMruJiFBYyavcMXRqQT3rr2n41w",
        ]
        
        let coin = Bitcoin(isTestnet: false, apiKeys: [:])
        print(coin.displayName + " - test_address - START!")
        XCTAssertEqual("Bitcoin", coin.displayName)
        XCTAssertEqual("BTC", coin.coinSymbol)
        XCTAssertEqual( true, coin.useCompressedAddr)
        try doTestCoin(coin: coin, pubkeys: PUBKEY_BTC, addresses: ADDRESS_SEGWIT_BTC, privkeys: PRIVKEY_WIF_BTC)
        print(coin.displayName + " - test_address - FINISH!")
        print("===============================\n\n\n")
    }
    
    /* BTCTEST */
    func test_btctest() throws {
        
        let PUBKEY_BTCTEST=[
            "02860988886ecd730c1bd2f4d5d8a015492aa656f92d7dff09ef0f951677211a9a",
            "021a3d3978e501156197af1dc22ba09fd1597251de126c27448cf67a91064f3ede",
            "021f3d54734d7ac715fba56650d4a8fa12ab64939c8256729eba78ef2188fb4a5c",
            "0381872214b49468e718ba324bfb91c9a4a9b777339b1abdc8167030a1f33f916a",
            "02393edebdbe0c8886e1954c8791094393b4b160a96e32e7d799dfb7ea65dbc0d9",
        ]

        let ADDRESS_LEGACY_BTCTEST=[
             "mpinvcSCUmojQm64yDJzqfXg5NSuDCNX5k",
            "mgAYcUwkxyXq1N5crAXEcikty78ey2vBvt",
            "mghgGiTJkeJmpUyGX42QtVRFN95wnoWHxV",
            "mzRVdJPhiVVFFcr7vZv5spjgTKdk1HUh5E",
            "mnn9xeNVv9Dix2v2QMnZwY2Qhpwb6HCr4R",
        ]

        let ADDRESS_SEGWIT_BTCTEST=[
            "tb1qvnmy6khtlw06w49y2wzlmxn2xu09lyr7mfd794",
            "tb1qquwqn8mq444yzraecu9rwszws4zhguggjp3ldk",
            "tb1qpnl4xuh8v4s5wftjnmm9srvchya64kje0nepyr",
            "tb1qea3qcu5vmf6js2axyyzyzx9ef3x0k84g2vh43v",
            "tb1qf75dhyp0txvey0ll9gmc6kzxtmaqpzgwqzg7uz",
        ]

        let PRIVKEY_WIF_BTCTEST=[
            "cRWGHNwyxeZaw4B2XxogNsmyiahQdUdjoRFtMWew7CQbebPqHuyd",
            "cPQjd8KzYQ8T9N6XTFrQgjp9gkHCVcwukgiw8xfNf4P1zsR74Qus",
            "cSdfwpP9djT15W6XdxdvWyjqGPk3C1a38hZucUTx1pjNMKjeaJFp",
            "cQLHgHLBxdtePeXeBUhYj5rPs3CVP7GKMdQ4JmMHvz6DfjkhtWUo",
            "cUpjKR37hJX3tnkKN8Ui1stxFKp1LK8BUf1bEevFy5fwhervSfBi",
        ]
        
        let isTestnet = true
        let coin = Bitcoin(isTestnet: isTestnet, apiKeys: [:])
        print(coin.displayName + " - test_address - START!")
        XCTAssertEqual("Bitcoin Testnet", coin.displayName)
        XCTAssertEqual("BTCTEST", coin.coinSymbol)
        XCTAssertEqual( true, coin.useCompressedAddr)
        try doTestCoin(coin: coin, pubkeys: PUBKEY_BTCTEST, addresses: ADDRESS_SEGWIT_BTCTEST, privkeys: PRIVKEY_WIF_BTCTEST)
        print(coin.displayName + " - test_address - FINISH!")
        print("===============================\n\n\n")
    }
    
    /* LTC */
    func test_ltc() throws {
        let PUBKEY_LTC=[
        "031f0ed4b5cbd756626ec5f108f19b29fff7e93670e083a21cc32265ab4f4adece",
        "036f4cc9dbdc277c673870ad95d9e250119fe264f1905deab8de1ebdefc8ea45a4",
        "0294372dfc1cf72677bb3d86d93152261483d77870de046f3b859a97cfd9aca2c4",
        "02468a479f0e51a943e13173f827f7af43c51f864c8690a988f5b21975cd2d5bbe",
        "035f96c6cb9e2f0b372976c65766882a4d2d57954aa713ec9c35109fe58d23fdbc",
        ]
        let ADDRESS_LEGACY_LTC=[
        "Lc7WkFsqnS6bYrCYqdWzt5CatK2EkmLB6K",
        "LavvkpWGy9RteJXrhLYpK7d13oV8bqsaey",
        "LM7ScWi4LPQ3au34wSMUJ5C1HfNd5A6NN3",
        "LM9xJXSELgWhqYuTTsmVMw4s4pMiuZKvvH",
        "LbASsVLAwx7eZZBU7XG46XdgwJ8Uty15fa",
        ]
        let ADDRESS_SEGWIT_LTC=[
        "ltc1qh9p90tp8ffkyqsh6ptpa9hrnkgzsn0ul232qjm",
        "ltc1q43y6auh4q9wzq6n047tyucejt3sdruurtlqz7z",
        "ltc1qzj6sz4j35tjup6h6ytnx66utp54qzu0yyfeher",
        "ltc1qz5hfa7s5svk7zquc3zhcjkprkk6mtvyk5k74jl",
        "ltc1q4mvr4j9apt43gpytgwk92djw76c689z6qmn50e",
        ]
        let PRIVKEY_WIF_LTC=[
        "T87X7mAR3JkHb9nBSiyZnNTcnTZ31XTLbbYuP2gMF1uCpyxa6kgN",
        "T4A27wtfX4W7cFVDiLhNAYyqco3SdqEDSYFvrET8PGxwP8qMdGmn",
        "T9ywaRQ5iWuTH366NNzS6nKNUDX3XQda3KBH9iBmLgDqCiLMH1NT",
        "T4EoWASE91AoELW3wCs4Z7wxFuaieHd99eHeSswBVyg21fRPrLpF",
        "T3svmt7X7wWsWTWQ6e7vSj7S14KVLQSkbsEZ7rrYNJdjLZSYpAAo",
        ]
        
        let isTestnet = false
        let coin = Litecoin(isTestnet: isTestnet, apiKeys: [:])
        print(coin.displayName + " - test_address - START!")
        XCTAssertEqual("Litecoin", coin.displayName)
        XCTAssertEqual("LTC", coin.coinSymbol)
        XCTAssertEqual( true, coin.useCompressedAddr)
        try doTestCoin(coin: coin, pubkeys: PUBKEY_LTC, addresses: ADDRESS_SEGWIT_LTC, privkeys: PRIVKEY_WIF_LTC)
        print(coin.displayName + " - test_address - FINISH!")
        print("===============================\n\n\n")
    }

    /* LTCTEST */
    func test_ltctest() throws {
    
        let PUBKEY_LTCTEST=[
            "02860988886ecd730c1bd2f4d5d8a015492aa656f92d7dff09ef0f951677211a9a",
            "021a3d3978e501156197af1dc22ba09fd1597251de126c27448cf67a91064f3ede",
            "021f3d54734d7ac715fba56650d4a8fa12ab64939c8256729eba78ef2188fb4a5c",
            "0381872214b49468e718ba324bfb91c9a4a9b777339b1abdc8167030a1f33f916a",
            "02393edebdbe0c8886e1954c8791094393b4b160a96e32e7d799dfb7ea65dbc0d9",
        ]
        let ADDRESS_LEGACY_LTCTEST=[
            "mpinvcSCUmojQm64yDJzqfXg5NSuDCNX5k",
            "mgAYcUwkxyXq1N5crAXEcikty78ey2vBvt",
            "mghgGiTJkeJmpUyGX42QtVRFN95wnoWHxV",
            "mzRVdJPhiVVFFcr7vZv5spjgTKdk1HUh5E",
            "mnn9xeNVv9Dix2v2QMnZwY2Qhpwb6HCr4R",
        ]
        let ADDRESS_SEGWIT_LTCTEST=[
            "tltc1qvnmy6khtlw06w49y2wzlmxn2xu09lyr7zp0q4u",
            "tltc1qquwqn8mq444yzraecu9rwszws4zhguggtfnpal",
            "tltc1qpnl4xuh8v4s5wftjnmm9srvchya64kjekmml52",
            "tltc1qea3qcu5vmf6js2axyyzyzx9ef3x0k84gny4tp9",
            "tltc1qf75dhyp0txvey0ll9gmc6kzxtmaqpzgwe22qvt",
        ]
        let PRIVKEY_WIF_LTCTEST=[
            "cRWGHNwyxeZaw4B2XxogNsmyiahQdUdjoRFtMWew7CQbebPqHuyd",
            "cPQjd8KzYQ8T9N6XTFrQgjp9gkHCVcwukgiw8xfNf4P1zsR74Qus",
            "cSdfwpP9djT15W6XdxdvWyjqGPk3C1a38hZucUTx1pjNMKjeaJFp",
            "cQLHgHLBxdtePeXeBUhYj5rPs3CVP7GKMdQ4JmMHvz6DfjkhtWUo",
            "cUpjKR37hJX3tnkKN8Ui1stxFKp1LK8BUf1bEevFy5fwhervSfBi",
        ]
        
        let isTestnet = true;
        let coin = Litecoin(isTestnet: isTestnet, apiKeys: [:])
        print(coin.displayName + " - test_address - START!")
        XCTAssertEqual("Litecoin Testnet", coin.displayName)
        XCTAssertEqual("LTCTEST", coin.coinSymbol)
        XCTAssertEqual( true, coin.useCompressedAddr)
        try doTestCoin(coin: coin, pubkeys: PUBKEY_LTCTEST, addresses: ADDRESS_SEGWIT_LTCTEST, privkeys: PRIVKEY_WIF_LTCTEST)
        print(coin.displayName + " - test_address - FINISH!")
        print("===============================\n\n\n")
    }
        
    /* BCH */
    func test_bch() throws{
        // path: m/0/*
        let PUBKEY_BCH=[
            "037f38c987d3e7ca6534b87588bc26c8c77739316c6af2b01ca5879c8d292472c2",
            "020649a9b59a1f986efed9320fe61f9b1ae217e35b37a71bfe166d695742987b6d",
            "0384c82879d42884922dfd3a9a1875730a6f642360fee8d28adb9f60c340713b85",
            "03c056e24e61951169616e6a8e019ff54849822d65b9d947361b6bf05203ad8d15",
            "02a931823029e1e305880d8bdc17f2a413c7c7cdc9eefffc4ace0777ef9d944977",
        ]
        let ADDRESS_BCH=[
            "1Cr354KVskWhpFtEigcztiWaqvJi35Hrfn",
            "18y7pcKS3zLEByHtHVwqqep59jSUduumMR",
            "1KVpBLfQVQYQzm27uDvEL13HeDd9PWqzJ9",
            "1Cj1qKrMQDBLaBFsUqZtxUKRe8fckR9hBk",
            "1BBSYAkhtNCZWrSSBZaQzwseEbH9YYXjeL",
        ]
        // TODO: move to cashaddress
        let ADDRESS_BCH_CASHADDR=[
            "bitcoincash:qzq77lnqvtk8afrsjr2qqcha39lhm4wcmq5e75xsrg",
            "bitcoincash:qptkth3meaxcwla5rgy4yxdqtck47ptt75k74y0y92",
            "bitcoincash:qr9w2jeq3qnn8k2ty7h8vvaa54lfelcjys05gczr8n",
            "bitcoincash:qzqfhr9dapn4qvgcufnulgu8lstk5zey2cdpepg8mg",
            "bitcoincash:qph640pg8rtdcf4wfys3ngfacpd9r7kt6vgrkfj820",
        ]
        let ADDRESS_SEGWIT_BCH: [String]=[]
        let PRIVKEY_WIF_BCH=[
            "L21CkkjKvmcWr5k9nEv5kYKD55QRFnU3D2q7T9QZQmqb1fz9N3e4",
            "Kz5BumoRSaovsfgPN13FsFp3jxjt2zmKtWfoWp2etF9Rp2adWVAP",
            "L2awcdfoabd43SzCJxcVmnSsewuazMFpfPhLMTreAqLuotcNBfYG",
            "L2dbLNq6UMCCvpCimw2nyCeAYG8HxAHmxAUTSQhzFemD1yzoaNiS",
            "L2RfBWTtdAGnTyLApZKWekgueyVh7twuJ9DxF3dkWYgj8WxC4JsW",
        ]
        
        let isTestnet = false
        let coin = BitcoinCash(isTestnet: isTestnet, apiKeys: [:])
        print(coin.displayName + " - test_address - START!")
        XCTAssertEqual("Bitcoin Cash", coin.displayName)
        XCTAssertEqual("BCH", coin.coinSymbol)
        XCTAssertEqual( true, coin.useCompressedAddr)
        try doTestCoin(coin: coin, pubkeys: PUBKEY_BCH, addresses: ADDRESS_BCH_CASHADDR, privkeys: PRIVKEY_WIF_BCH)
        print(coin.displayName + " - test_address - FINISH!")
        print("===============================\n\n\n")
    }
        
    /* ETH*/
    func test_eth() throws {
        let PUBKEY_ETH=[
            "037f38c987d3e7ca6534b87588bc26c8c77739316c6af2b01ca5879c8d292472c2",
            "020649a9b59a1f986efed9320fe61f9b1ae217e35b37a71bfe166d695742987b6d",
            "0384c82879d42884922dfd3a9a1875730a6f642360fee8d28adb9f60c340713b85",
            "03c056e24e61951169616e6a8e019ff54849822d65b9d947361b6bf05203ad8d15",
            "02a931823029e1e305880d8bdc17f2a413c7c7cdc9eefffc4ace0777ef9d944977",
        ]
        let ADDRESS_ETH_CHECKSUM=[
            "0x83da5A7e7E02E88237a6AF11598e8322a12CCda1",
            "0x3273BcF2b748Ea196663Ae900B7Cf5C3a5b9B912",
            "0xb62990a87649B658D0f49158ed68Ab8921442354",
            "0xe2A7152113cC018EC24F88C67fC8CE1C47B989a5",
            "0xc29bB40B3265Fa3c0925B38916D1C0C92e54E5A4",
        ]
        let ADDRESS_ETH=[
            "0x83da5a7e7e02e88237a6af11598e8322a12ccda1",
            "0x3273bcf2b748ea196663ae900b7cf5c3a5b9b912",
            "0xb62990a87649b658d0f49158ed68ab8921442354",
            "0xe2a7152113cc018ec24f88c67fc8ce1c47b989a5",
            "0xc29bb40b3265fa3c0925b38916d1c0c92e54e5a4",
        ]
        //let ADDRESS_SEGWIT_ETH=[]
        let PRIVKEY_ETH=[
            "0x8ec0b10753bb2c7c8462f3328afb86bb45f2c766f8c2e2bc4fd93b13ae4732ea",
            "0x5520cfb01a87374da0989fcbe4d7b5fe99f262bb93ce8adfff4273a6e62ff127",
            "0xa01bfb418815a1c8063caa9503b4b6e60897b4c5d1deefc2fd61fc6ac0d61c6a",
            "0xa179055a8bba685407579bf8a1465bb52323095a5dde5ce6a6ff00720afeea27",
            "0x9b55672fd34e5d0b597fe801910c23186e6f8b03443ddeb5b6a4652a089637ff",
        ]
        // ETH uses uncompressed pubkeys...
        let PRIVKEY_WIF_ETH_COMPRESSED=[
            "L21CkkjKvmcWr5k9nEv5kYKD55QRFnU3D2q7T9QZQmqb1fz9N3e4",
            "Kz5BumoRSaovsfgPN13FsFp3jxjt2zmKtWfoWp2etF9Rp2adWVAP",
            "L2awcdfoabd43SzCJxcVmnSsewuazMFpfPhLMTreAqLuotcNBfYG",
            "L2dbLNq6UMCCvpCimw2nyCeAYG8HxAHmxAUTSQhzFemD1yzoaNiS",
            "L2RfBWTtdAGnTyLApZKWekgueyVh7twuJ9DxF3dkWYgj8WxC4JsW",
        ]
        // generated from privkey with https://learnmeabitcoin.com/technical/wif
        let PRIVKEY_WIF_ETH=[
            "5JuA1Q3nyb8983SBbifm89TL3jgk74xWxHjAcq89hjLAX5qL36V",
            "5JTn4oQCt7JRtoptjpb3Tnx4nz31gshQK1qDMMAtdXr2znqU8KK",
            "5K2oMm75D9JENrPUV5tzisAwXM9HmG1e5cxMhS7iVxp75Mb52Do",
            "5K3QBjZCD62dgqJcHyeZcqrexZt3UuQHXd8ada1gFeZDh8Bc3Di",
            "5JzhNQtrkzP9wbWieWXUZa1S55C2qgs3na8U1vAEUzUaZZ9Vgpi",
        ]
        
        let isTestnet = false;
        let coin = Ethereum(isTestnet: isTestnet, apiKeys: [:])
        print(coin.displayName + " - test_address - START!")
        XCTAssertEqual("Ethereum", coin.displayName)
        XCTAssertEqual("ETH", coin.coinSymbol)
        XCTAssertEqual(false, coin.useCompressedAddr)
        try doTestCoin(coin: coin, pubkeys: PUBKEY_ETH, addresses: ADDRESS_ETH, privkeys: PRIVKEY_WIF_ETH)
        print(coin.displayName + " - test_address - FINISH!")
        print("===============================\n\n\n")
    }
    
    /* XCP */
    func testXcp() throws {
        
        let PUBKEY_XCP = [
            "03b7b3957daedecee4488dcb0b8cf3f3372d64d5c559953d2a2539f55e6474c8ce",
            "03e5c1e865d21a239c6639e75586df1f0a5e59853694601e78dccb22481fad08c0",
            "03f21a3b7ff93a4396d886b04b045b8a4dfaa3e13ae169adf36a7390f65af964c0",
            "035f6cb6545543c6b69ba402e19362a71c9ff58a93f8c2d812e0a6c27c6304e5d2",
            "03e1d8b41fa14419293b29ad6f98d5bd1827ae21b5f1083a7cc001955db2ee628c",
        ]
        
        let ADDRESS_LEGACY_XCP = [
            "1Q6QXhpreAW8wDRwaL6jvdEcbbceFMw2mv",
            "1976pT5yu88hDa7HsQK76tpbyYtPTyN3cF",
            "1QC6JNGbXdmQFkBp69yFFXdYZKvXtfCeEx",
            "14Kz6dHFJjJNqj2hvQ84vSzYq78T9pmoWi",
            "1Lr8JCa936osnV288Jm3LYBKKvvvQJkdfy",
        ]
        
        let ADDRESS_SEGWIT_XCP = [
            "bc1ql4gf6wjve0enmmsvr0vrv4f0v9cnxzcnhpjnx2",
            "bc1qtr59h4kqargu5les2as8w2tumqreh58ew2ks5d",
            "bc1qle37gu93ja9csxndeu7q57g49jf5j4qsckw9g0",
            "bc1qy3lcdhn4crpev6ppejlt20kzhdg528f3t4wp27",
            "bc1qmx6deexe6r8vvn775e5hjur78g2q4n5fe0fzyn",
        ]
        
        let PRIVKEY_WIF_XCP = [
            "KzsYHPmjK3VbtFvRL4PbaEAnUePcgQjJZC1B4RjcR1AXbZbC5Yfu",
            "L4cWMhJWvJwBFv1WrwfoTZYW4EDrT33KSoYtQEfnruzgNiupUNnq",
            "L4wZXSWJNr2fWbmf2Pfh1XyFew9tSog65nxUiA6767fhot4kGBeX",
            "L1Xb8kjGUgT322K2pGpUV3EYzzUucT9hsR34mAphtY1C8RwVqLWP",
            "KxF9SWjzRygz8DP32RdPhak19aMruJiFBYyavcMXRqQT3rr2n41w",
        ]
        
        let coin = Counterparty(isTestnet: false, apiKeys: [:])
        print(coin.displayName + " - test_address - START!")
        XCTAssertEqual("Counterparty", coin.displayName)
        XCTAssertEqual("XCP", coin.coinSymbol)
        XCTAssertEqual( true, coin.useCompressedAddr)
        try doTestCoin(coin: coin, pubkeys: PUBKEY_XCP, addresses: ADDRESS_LEGACY_XCP, privkeys: PRIVKEY_WIF_XCP)
        print(coin.displayName + " - test_address - FINISH!")
        print("===============================\n\n\n")
    }
    
    
    //
    //         SUBFUNCTIONS
    //
    
    func doTestCoin(coin: BaseCoin, pubkeys: [String], addresses: [String], privkeys: [String] ) throws {
        
        for index in 0..<pubkeys.count {
            print("INDEX: \(index)")
            let pubkeyHex = pubkeys[index]
            var pubkeyBytes = pubkeyHex.hexToBytes
            
            // uncompress pubkey if necessary
            if (!coin.useCompressedAddr && pubkeyBytes.count<65){
                //pubkeyBytes = self.compressedToUncompressed(compKey: pubkeyBytes)
                var privkeyBytes = wif2priv(privkeyWIF: privkeys[index])
                pubkeyBytes = privkeyToUncompressed(privkey: privkeyBytes)
                print("pubkeyBytes (uncompressed)= " + pubkeyBytes.bytesToHex)
            }
            
            var addr = try coin.pubToAddress(pubkey: pubkeyBytes)
            print("address: \(addr)")
            print("ADDRESS: \(addresses[index])")
            XCTAssertEqual(addr, addresses[index])
            
            if (index<privkeys.count){
                var privkeyBytes = wif2priv(privkeyWIF: privkeys[index])
                var privkeyWif = coin.encodePrivkey(privkey: privkeyBytes)
                print("privkey_wif= " + privkeyWif)
                print("PRIVKEY_WIF= " + privkeys[index])
                XCTAssertEqual(privkeyWif, privkeys[index])
            } else {
                print("WIF not supported => skipping test_WIF")
            }
            
            let url = coin.getAddressWebLink(address: addr) ?? "unsupported"
            print("URL= " + url)
        }
    }
    
    // convert wif String to byte[]
    func wif2priv(privkeyWIF: String) -> [UInt8] {
        
        let decoded = [UInt8](Base58.decode(privkeyWIF))
        print("privkey decoded= " + decoded.bytesToHex)
        
        // https://learnmeabitcoin.com/technical/wif
        // First byte is version
        // Last 4 bytes are checksum
        // last 5th byte (optional) is compression byte 01 if compressed pubkey
        var privkey: [UInt8] = []
        if (decoded.count == 38){
            privkey = Array(decoded[1..<(decoded.count-5)]) // discard 1st byte & last 5 bytes
        } else if (decoded.count == 37){
            privkey = Array(decoded[1..<(decoded.count-4)]) // discard 1st byte & last 4 bytes
        }
        print("trimmed decoded= " + privkey.bytesToHex)
        if (privkey.count == 33){
            privkey = Array(privkey[1..<privkey.count])
        }
        
        return privkey
    }
    
    // get uncompressed public key from private value...
    func privkeyToUncompressed(privkey: [UInt8]) -> [UInt8] {
                    
        //  Private key
        let privateKey = try! secp256k1.Signing.PrivateKey(rawRepresentation: privkey, format: .uncompressed)

        //  Public key
        print(String(bytes: privateKey.publicKey.rawRepresentation))
        return [UInt8](privateKey.publicKey.rawRepresentation)
    }
}
