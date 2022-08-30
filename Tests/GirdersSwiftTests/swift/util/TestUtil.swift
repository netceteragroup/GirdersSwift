//
//  TestUtil.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 16.08.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestUtil: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    static let valueConstant = "value"
    
    func testTranslate_returnsQuestionsMarkedKey_whenTranslationNotFound() {
        class MockNSBundle: Bundle {
            override func localizedString(forKey key: String,
                                          value: String?,
                                          table tableName: String?) -> String {
                return ""
            }
        }
        
        let key = "TestKey"
        XCTAssertEqual("?\(key)?", translate(key, bundle: MockNSBundle()))
    }
    
    func testTranslate_returnsTranslation_whenTranslationFound() {
        class MockNSBundle: Bundle {
            /// Mocked function returns key + constant as found value
            override func localizedString(forKey key: String,
                                          value: String?,
                                          table tableName: String?) -> String {
                return key + TestUtil.valueConstant
            }
        }
        
        XCTAssertEqual("TestKey" + TestUtil.valueConstant,
                       translate("TestKey", bundle: MockNSBundle()))
        XCTAssertEqual("hex string: 123" + TestUtil.valueConstant,
                       translate("hex string: %d", 123, bundle: MockNSBundle()))
    }
    
}
