//
//  TestUtilURL.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 22.08.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestUtilURL: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatAppendQueryStringReturnsSelfOnEpmtyQueryString() {
        let sampleUrl = URL(string: "https://www.example.com")
        //TODO: test with nil (Testing with Nil is not posible, args are not optional types)
        let withQuery = sampleUrl?.appendQueryString(queryString: "")
        XCTAssertEqual(sampleUrl, withQuery)
    }
    
    func testThatAppendQueryStringReturnsUrlWithQuery() {
        // update the tests.
        let sampleUrl = URL(string: "https://www.example.com")
        let querryString = "?first=foo&second=bar"
        let urlWithQuery = sampleUrl?.appendQueryString(queryString: querryString)
        let expectedUrlString = "https://www.example.com?first=foo&second=bar"
        let extpectedUrl = URL(string: expectedUrlString)
        
        //Equal URL Strings
        XCTAssertEqual(expectedUrlString, urlWithQuery?.absoluteString)
        
        //Equal URL Objects
        XCTAssertEqual(extpectedUrl, urlWithQuery)
    }
    
    func testThatAppendQueryStringReturnsUrlwithQueryWhenQuestionMarkIsAfterUrl() {
        let sampleUrl = URL(string: "https://www.example.com?")
        let querryString = "first=foo&second=bar"
        let urlWithQuery = sampleUrl?.appendQueryString(queryString: querryString)
        let expectedUrlString = "https://www.example.com?first=foo&second=bar"
        let extpectedUrl = URL(string: expectedUrlString)
        //Equal URL Strings
        XCTAssertEqual(expectedUrlString, urlWithQuery?.absoluteString)
        
        //Equal URL Objects
        XCTAssertEqual(extpectedUrl, urlWithQuery)
    }
    
    func testThatAppendQueryStringReturnsUrlwithQueryWhenQuestionMarkIsNotProvided() {
        let sampleUrl = URL(string: "https://www.example.com")
        let querryString = "first=foo&second=bar"
        let urlWithQuery = sampleUrl?.appendQueryString(queryString: querryString)
        let expectedUrlString = "https://www.example.com?first=foo&second=bar"
        let extpectedUrl = URL(string: expectedUrlString)
        //Equal URL Strings
        XCTAssertEqual(expectedUrlString, urlWithQuery?.absoluteString)
        
        //Equal URL Objects
        XCTAssertEqual(extpectedUrl, urlWithQuery)
    }
    
    func testThatAppendQueryStringReturnsNilOnInvalidQueryString() {
        let sampleUrl = URL(string: "https://www.example.com")
        let querryString = "SomethingInvalid&&!!##"
        let urlWithQuery = sampleUrl?.appendQueryString(queryString: querryString)
        
        XCTAssertNil(urlWithQuery)
    }
    
    func testThatInvalidUrlReturnsNil() {
        let sampleUrl = URL(string: "ThisIsNotAURLL  ")
        
        XCTAssertNil(sampleUrl)
    }
    
    //Possible bug: Special Simbols is invalid url
    func testThatAppendQueryStringReturnsUrlWithQueryWithSpecialCharacters() {
        let sampleUrl = URL(string: "https://www.example.com")
        let querryString = "first=Zürich&second=Neuchâtel"
        let urlWithQuery = sampleUrl?.appendQueryString(queryString: querryString)
        let expectedUrlString = "https://www.example.com?first=Zürich&second=Neuchâtel"
        let extpectedUrl = URL(string: expectedUrlString)
        
        XCTAssertNil(urlWithQuery)

        XCTAssertEqual(urlWithQuery?.absoluteString, extpectedUrl?.absoluteString)
    }
    
    func testThatAppendQueryStringReturnsNilOnQueryStringWithSpacesInParams() {
        let sampleUrlString = "https://www.example.com?"
        let sampleUrl = URL(string: sampleUrlString)
        let sampleQuery = "address=west 34&zip=32";
        let urlWithAppendedQuery = sampleUrl?.appendQueryString(queryString: sampleQuery)
        
        XCTAssertNil(urlWithAppendedQuery)
    }
    
    func testThatAppendQueryStringReturnsNilOnQueryStringWithUmlautesInParams() {
        let sampleUrlString = "https://www.example.com?"
        let sampleUrl = URL(string: sampleUrlString)
        let sampleQuery = "address=westä&zip=32";
        let urlWithAppendedQuery = sampleUrl?.appendQueryString(queryString: sampleQuery)
        
        XCTAssertNil(urlWithAppendedQuery)
    }
    
    func testThatAppendQueryStringDoesNotOverrideExistingQuery() {
        let sampleUrlString = "https://www.example.com?first=foo&second=bar"
        let sampleUrl = URL(string: sampleUrlString)
        let sampleQuery = "third=ham&fourth=spam";
        let urlWithAppendedQuery = sampleUrl?.appendQueryString(queryString: sampleQuery)
        let expectedUrlString = "https://www.example.com?first=foo&second=bar&third=ham&fourth=spam"
        let expectedUrl = URL(string: expectedUrlString)
        
        //Equal URL Stirngs
        XCTAssertEqual(urlWithAppendedQuery?.absoluteString, expectedUrlString)
        
        //Equal URL Objects
        XCTAssertEqual(urlWithAppendedQuery, expectedUrl)
    }
    
    func testThatAppendQueryStringWithQuestionMarkToURLWithAlreadyExistingParamsReturnsValidURL() {
        let sampleUrlString = "https://www.example.com?first=foo&second=bar"
        let sampleUrl = URL(string: sampleUrlString)
        let sampleQuery = "?first=ham&fourth=spam";
        let urlWithAppendedQuery = sampleUrl?.appendQueryString(queryString: sampleQuery)
        let expectedUrlString = "https://www.example.com?first=foo&second=bar&first=ham&fourth=spam"
        let expectedUrl = URL(string: expectedUrlString)
        
        //Equal URL Stirngs
        XCTAssertEqual(urlWithAppendedQuery?.absoluteString, expectedUrlString)
        
        //Equal URL Objects
        XCTAssertEqual(urlWithAppendedQuery, expectedUrl)
    }
    
    func testThatAppendQueryStringWithAlreadyExistingParams() {
        let sampleUrlString = "https://www.example.com?first=foo&second=bar"
        let sampleUrl = URL(string: sampleUrlString)
        let sampleQuery = "first=ham&fourth=spam";
        let urlWithAppendedQuery = sampleUrl?.appendQueryString(queryString: sampleQuery)
        let expectedUrlString = "https://www.example.com?first=foo&second=bar&first=ham&fourth=spam"
        let expectedUrl = URL(string: expectedUrlString)
        
        //Equal URL Stirngs
        XCTAssertEqual(urlWithAppendedQuery?.absoluteString, expectedUrlString)
        
        //Equal URL Objects
        XCTAssertEqual(urlWithAppendedQuery, expectedUrl)
    }
}
