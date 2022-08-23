 //
//  TestConfiguration.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 07.09.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestConfiguration: XCTestCase {
    
    public let debugFlag: Bool = true;
    var configurationTest = Configuration(bundle: Bundle(for: TestConfiguration.self))
    
    func testThatConfigurationEnvValuesCanBeLoaded() {
        XCTAssertNotNil(configurationTest.modeConfiguration)
        
        XCTAssertTrue(configurationTest.modeConfiguration?.count == 1)

        let baseURL = configurationTest.modeConfiguration?["baseUrl"] as? String
        
        XCTAssertEqual(baseURL, "https://base.url.env")

    }
    
    func testThatDefaultConfigurationValuesCanBeLoaded() {
        XCTAssertNotNil(configurationTest.defaultConfiguration)
        
        XCTAssertTrue(configurationTest.defaultConfiguration?.count == 6)
        
        let name = configurationTest.defaultConfiguration?["Name"] as? String
        
        XCTAssertEqual(name, "User")

    }
    
    func testThatConfigurationValuesCanBeLoadedWithSubscript() {
        
        let last = configurationTest["Last"] as? String
        
        XCTAssertEqual(last, "Item")

    }
    
}
