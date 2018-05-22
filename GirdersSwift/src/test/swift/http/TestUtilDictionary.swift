//
//  TestUtilDictionary.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 22.08.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestUtilDictionary: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //TODO: test different encoding / with umlauts, whitespaces, special characters
    //TODO: test with nil
    //Possible bug: Query is built from back to front
    func testThatUrlEncodedQueryStringReturnsExpectedQueryString() {
        var queryDictionary: [String:String] = [:]
        
        queryDictionary.updateValue("spam", forKey: "first")
        queryDictionary.updateValue("ham", forKey: "second")
        
        let query = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .utf8)
        XCTAssertEqual(query, "second=ham&first=spam")
        
    }
    
    //Possible bug: Nil gets encoded as String
    func testThatUrlEncodedQueryStringDoesNotEncodeNil() {
        let queryDictionary = ["first" : "foo", "second" : nil ]
        
        let query = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .utf8)
        XCTAssertFalse(query.contains("nil"))
    }
    
    func testThatUrlEncodedQueryStringEncodesWhiteSpaces() {
        let queryDictionary = ["destination" : "  Skopje    ", "city" : "Zürich" ]
        
        let query = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .utf8)
        XCTAssertEqual(query, "city=Z%C3%BCrich&destination=%20%20Skopje%20%20%20%20")
    }
    

    func testThatUrlEncodedQueryStringEncodesSpecialCharacters() {
        let queryDictionary = ["destination" : "Skopje#", "city" : "Zürich$" ]
        
        let query = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .utf8)
        XCTAssertEqual(query, "city=Z%C3%BCrich%24&destination=Skopje%23")
    }
    
    func testThatUrlEncodedQueryStringEncodesUmlaumts() {
        let queryDictionary = ["first" : "foo", "city" : "Zürich" ]
        
        let query = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .utf8)
        XCTAssertEqual(query, "city=Z%C3%BCrich&first=foo")
    }
    
    func testThatUrlEncodedQueryStringReturnsSameEncodingForDifferentEncodings() {
        let queryDictionary = ["destination" : "Skopje#", "city" : "Zürich$" ]
        
        let queryUtf8 = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .utf8)
        let queryAscii = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .ascii)
        let queryIsoLatin1 = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .isoLatin1)
        let queryUnicode = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .unicode)
        
        XCTAssertEqual(queryUtf8, "city=Z%C3%BCrich%24&destination=Skopje%23")
        XCTAssertEqual(queryAscii, "city=Z%C3%BCrich%24&destination=Skopje%23")
        XCTAssertEqual(queryIsoLatin1, "city=Z%C3%BCrich%24&destination=Skopje%23")
        XCTAssertEqual(queryUnicode, "city=Z%C3%BCrich%24&destination=Skopje%23")
    }
    
    func testThatUrlEncodedQueryStringEncodesBoolean() {
        let queryDictionary = ["first" : true, "second" : false, "third" : false]
        
        let query = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .utf8)
        
        XCTAssertEqual(query, "second=false&third=false&first=true")
    }
    
    func testThatUrlEncodeQueryStringCanHandleEmptyDictionary() {
        let queryDictionary = [String: Any]()
        
        let query = queryDictionary.urlEncodedQueryStringWithEncoding(encoding: .utf8)
        
        XCTAssertEqual(query, "")
        
    }
    
    func testThatUrlEncodeQueryStringWorksWithDifferentKeyTypes() {
        let queryDict = [1 : "one", 2 : "two", 3 : "three"]
        
        let query = queryDict.urlEncodedQueryStringWithEncoding(encoding: .utf8)
        
        XCTAssertEqual(query, "2=two&3=three&1=one")
    }
}
