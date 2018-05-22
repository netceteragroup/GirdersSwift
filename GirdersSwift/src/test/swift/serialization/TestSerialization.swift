//
//  TestSerialization.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 29.08.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestSerialization: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatSerializationRetursDictionary() {
        let mockObject = MockClass()
        
        XCTAssertNotNil(mockObject.toDictionary())
        XCTAssertNotNil(mockObject.toData())
    }
    
}

class MockClass : Serializable {
    func toDictionary() -> [String : Any] {
        var dictionary: [String : Any] = [:]
        dictionary.updateValue(name, forKey: "name")
        dictionary.updateValue(id, forKey: "id")
        dictionary.updateValue(date, forKey: "date")
        
        return dictionary
    }
    
    let name: String
    let id: Int
    let date: Double
    
    public init() {
        name = "Exmaple"
        id = 123
        date = Date().timeIntervalSince1970
    }
}
