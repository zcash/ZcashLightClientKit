//
//  ZcashLightClientKitTests.swift
//  ZcashLightClientKitTests
//
//  Created by Jack Grigg on 5/8/19.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import XCTest
import SwiftGRPC

@testable import ZcashLightClientKit

class ZcashLightClientKitTests: XCTestCase {
    
    var latestBlock: BlockID!
    
    var service: LightWalletGRPCService!
    override func setUp() {
        super.setUp()
        service = LightWalletGRPCService(channel: ChannelProvider().channel())
        
        latestBlock = try! service.latestBlock()
    }
    
    override func tearDown() {
        super.tearDown()
        service.channel.shutdown()
        service = nil
        latestBlock = nil
    }
    
    func testEnvironmentLaunch() {
        
        let address = Constants.address
        
        XCTAssertFalse(address.isEmpty, "Your \'\(Environment.lightwalletdKey)\' key is missing from your launch environment variables")
    }
    
    func testService() {
        
        // and that it has a non-zero size
        XCTAssert(self.latestBlock.height > 0)
        
    }
    
//    /**
//     LIGHTWALLETD KILLER TEST - DO NOT USE
//     */
//    func testBlockRangeService() {
//
//        let expect = XCTestExpectation(description: self.debugDescription)
//        let _ = try? service.getAllBlocksSinceSaplingLaunch(){ result in
//            print(result)
//            expect.fulfill()
//            XCTAssert(result.success)
//            XCTAssertNotNil(result.resultData)
//        }
//        wait(for: [expect], timeout: 10)
//    }
    
    func testBlockRangeServiceTilLastest() {
        let expectedCount: UInt64 = 99
        var count: UInt64 = 0
       
        
        let startHeight = self.latestBlock.height - expectedCount
        let endHeight = self.latestBlock.height
        
        guard let call = try? service.blockRange(startHeight: startHeight, endHeight: endHeight,result: {
            result in
            XCTAssert(result.success)
          
        }) else {
            XCTFail("failed to create getBlockRange( \(startHeight) ..<= \(endHeight)")
            return
        }
      
        
        var blocks = [CompactBlock]()
        while true {
            guard let block = try? call.receive() else {
               
                break
                
            }
            blocks.append(block)
            count += 1
        }
     
        XCTAssertEqual(expectedCount + 1, count)
        
    }
    
}

class Environment {
    static let lightwalletdKey = "LIGHTWALLETD_ADDRESS"
}
