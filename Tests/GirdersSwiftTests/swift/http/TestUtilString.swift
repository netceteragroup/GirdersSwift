//
//  TestUtilString.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 22.08.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestUtilString: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testThatUrlEncodedStringWithEncodinReturnEncoding() {
        var sampleUrlString = "http://www.example.com?ham=spam"
        let expectedString = "http%3A%2F%2Fwww.example.com%3Fham%3Dspam"
        sampleUrlString = sampleUrlString.urlEncodedStringWithEncoding()
        
        XCTAssertEqual(sampleUrlString, expectedString)
    }
    
    func testThatUrlEncodedStringWithEncodingReturnsSameStringWithoutSymbols() {
        var sampleUrlString = "example.com"
        let expectedString = "example.com"
        sampleUrlString = sampleUrlString.urlEncodedStringWithEncoding()
        
        XCTAssertEqual(sampleUrlString, expectedString)
    }
    
    func testThatIndexOfReturnExpectedIndex() {
        let sampleText = "The Quick Brown Fox Jumped over the Lazy Dog"
        let index = sampleText.indexOf(sub: "Quick")
        
        XCTAssertEqual(4, index)
    }
    
    func testThatSubscriptReturnsExpectedString() {
        let sampleText = "The Quick Brown Fox Jumped over the Lazy Dog"
        let range: Range<Int> = 0..<3
        let subscriptString = sampleText[range]
        
        XCTAssertEqual("The", subscriptString)
    }
    
}
