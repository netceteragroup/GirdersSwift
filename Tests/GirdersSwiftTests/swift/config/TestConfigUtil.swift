//
//  TestConfigUtil.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 01.09.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

//functions in Configuration work with Main Bundle
class TestConfigUtil: XCTestCase {
    
    private let testEnvironmentBundle = Bundle(for: TestConfigUtil.self)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatLoadConfigReturnsEmptyDictionaryWhenConfigNotFound() {
        let config = loadConfig(fromResource: "sampleConfig")
        
        XCTAssertEqual(config.count, 0)
    }
    
    func testThatLoadConfigReturnsDictionarywhenResourceFound() {
        let config = loadConfig(fromResource: "/GirdersSwift/src/test/resources/Configuration-env.plist", bundle: testEnvironmentBundle)
        
        XCTAssertEqual(config.count, 1)
    }
    
    func testThatPlistPathFindsExistingResources() {
        let filePath = plistPath(forResource: "Configuration", bundle: testEnvironmentBundle)

        XCTAssertNotNil(filePath)
    }

}
