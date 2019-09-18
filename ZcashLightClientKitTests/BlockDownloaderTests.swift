//
//  BlockDownloaderTests.swift
//  ZcashLightClientKitTests
//
//  Created by Francisco Gindre on 18/09/2019.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import XCTest
@testable import ZcashLightClientKit
class BlockDownloaderTests: XCTestCase {
    
    var downloader: CompactBlockDownloading!
    var service: LightWalletService!
    var storage: CompactBlockAsyncStoring!
    override func setUp() {
        service = LightWalletGRPCService(channel: ChannelProvider().channel())
        storage =  ZcashConsoleFakeStorage()
        downloader = CompactBlockDownloader(service: service, storage: storage)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        service = nil
        storage = nil
        downloader = nil
    }

    
    func testSmallDownload() {
        
        let expect = XCTestExpectation(description: self.description)
        expect.expectedFulfillmentCount = 2
        let lowerRange: BlockHeight = SAPLING_ACTIVATION_HEIGHT
        let upperRange: BlockHeight = SAPLING_ACTIVATION_HEIGHT + 99
        
        let range = CompactBlockRange(uncheckedBounds: (lowerRange,upperRange))
        downloader.downloadBlockRange(range) { (error) in
            expect.fulfill()
            XCTAssertNil(error)
            
            // check what was 'stored'
            self.storage.latestHeight { (result) in
                expect.fulfill()
                switch result {
                case .success(let height):
                    XCTAssertEqual(height, upperRange)
                    do {
                        let height = try self.downloader.latestBlockHeight()
                        XCTAssertEqual(height, upperRange)
                    } catch {
                        XCTFail("latest height failed")
                    }
                case .failure(let error):
                    XCTFail("Test Failed: \(error)")
                }
            }
        }
        
        wait(for: [expect], timeout: 2)
    }
    
    func testFailure() {
        let awfulDownloader = CompactBlockDownloader(service: AwfulLightWalletService(), storage: ZcashConsoleFakeStorage())
        
        let expect = XCTestExpectation(description: self.description)
        expect.expectedFulfillmentCount = 1
        let lowerRange: BlockHeight = SAPLING_ACTIVATION_HEIGHT
        let upperRange: BlockHeight = SAPLING_ACTIVATION_HEIGHT + 99
        
        let range = CompactBlockRange(uncheckedBounds: (lowerRange,upperRange))
        
        awfulDownloader.downloadBlockRange(range) { (error) in
            expect.fulfill()
            XCTAssertNotNil(error)
        }
        wait(for: [expect], timeout: 2)
    }
}
