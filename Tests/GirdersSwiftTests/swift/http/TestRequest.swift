//
//  TestRequest.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 29.08.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestRequest: XCTestCase {
    
    let mockGenerator = StandardRequestGenerator()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatRequestIsGeneratedWithEmptyParameters() {
        let urlSample = URL(string: "https://www.example.com/api")
        let parametersSample: [String : Any] = [:]
        let queryParameters: [String : Any] = [:]

        let mockRequest = Request(URL: urlSample!,
                                  method: .GET,
                                  parameters: parametersSample,
                                  queryParameters: queryParameters,
                                  requestGenerator: mockGenerator)
        
        XCTAssertNotNil(mockRequest)
    }
    
    func testThatRequestIsCreatedWithServiceEndpoint() {
        let request = Request(endpoint: TestServiceEndpoint.endpoint1)
        XCTAssertNotNil(request)
    }
    
    func testRequestWithAdditionalHeaders() {
        // Given
        let url = URL(string: "https://www.example.com/api")!
        let method: HTTPMethod = .GET
        let parameters: [String : Any] = [:]
        let additionalHeaders: [String: String] = ["User-Agent": "MyApp/1.0"]

        // When
        let request = Request(URL: url,
                              method: method,
                              parameters: parameters,
                              additionalHeaders: additionalHeaders,
                              requestGenerator: mockGenerator)
        let sortedHeaderFields = request.headerFields.sorted { $0.key < $1.key }
        let sortedDictionary = Dictionary(uniqueKeysWithValues: sortedHeaderFields)

        // Then
        XCTAssertEqual(sortedDictionary, ["Accept": "application/json", "User-Agent": "MyApp/1.0"])
    }

    func testRequestWithoutAdditionalHeaders() {
        // Given
        let url = URL(string: "https://www.example.com/api")!
        let method: HTTPMethod = .GET
        let parameters: [String : Any] = [:]

        // When
        let request = Request(URL: url,
                              method: method,
                              parameters: parameters,
                              requestGenerator: mockGenerator)
        let sortedHeaderFields = request.headerFields.sorted { $0.key < $1.key }
        let sortedDictionary = Dictionary(uniqueKeysWithValues: sortedHeaderFields)

        // Then
        XCTAssertEqual(sortedDictionary, ["Accept": "application/json"])
    }

    /**
         Testing == operator, when Requests are equal
    */
    func testThatRequestAndWraperAreEqual() {
        let endpoint: ServiceEndpoint = MockEndpoint()
        let leftRequestGirders: Request = Request(endpoint: endpoint)
        let rightRequestGirders: Request = Request(endpoint: endpoint)
        
        XCTAssertTrue(leftRequestGirders == rightRequestGirders)
    }
    
    
    /**
         Testing == operator, when Requests are not equal
    */
    func testThatRequestObjectsAreNotEqual() {
        let endpoint: ServiceEndpoint = MockEndpoint()
        let leftRequestGirders: Request = Request(endpoint: endpoint)
        let rightRequestGirders: Request = Request(URL: URL(string: "https://www.example.com")!, method: HTTPMethod.GET)
        
        XCTAssertFalse(leftRequestGirders == rightRequestGirders)
    }

}

/**
     Mock endpoing for Request Testing
 */
class MockEndpoint : ServiceEndpoint {
    
    var method: HTTPMethod {
        get {
            return HTTPMethod.GET
        }
    }
    
    var baseURL: URL {
        get {
            let urlString = "https://www.google.com/"
            return URL(string: urlString)!
        }
    }
    
    var path: String {
        get {
            return "/"
        }
    }
    
    var requestGenerator: RequestGenerator {
        get {
            return StandardRequestGenerator()
        }
    }
    
}


