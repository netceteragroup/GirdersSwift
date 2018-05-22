//
//  TestEndpoint.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 24.08.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestEndpoint: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEndpoint() {
        let request = Request(endpoint: TestServiceEndpoint.endpoint1)
        let expectedUrl = "https://www.netcetera.com/test"
        XCTAssertTrue(request.url.absoluteString == expectedUrl)
        let otherRequest = Request(endpoint: TestServiceEndpoint.endpoint2(path: "new-test"))
        let expectedSecondUrl = "http://www.example.com/new-test"
        XCTAssertTrue(otherRequest.url.absoluteString == expectedSecondUrl)
    }
    
    func testThatTestServiseEndpointGetterReturnsUrl() {
        let urlStirng = TestServiceEndpoint.endpoint1.baseURL
        
        XCTAssertNotNil(urlStirng)
    }
    
    func testThatRequestGenratorReturnsGenerator() {
        let generator = TestServiceEndpoint.endpoint1.requestGenerator
        
        XCTAssertNotNil(generator)
    }
    
    func testThatTestServiceEndpointAppendsExpectedQueryParameters() {
        let endpoint1Parameters = TestServiceEndpoint.endpoint1.parameters
        let endpoint2Parameters = TestServiceEndpoint.endpoint2(path: "new-test").parameters
        
        XCTAssertNotEqual(endpoint1Parameters.count , endpoint2Parameters.count)
    }
    
}

enum TestServiceEndpoint {
    case endpoint1
    case endpoint2(path: String)
}

extension TestServiceEndpoint : ServiceEndpoint {
    var method: HTTPMethod {
        get {
            switch self {
            case .endpoint1:
                return .GET
            case .endpoint2:
                return .POST
            }
        }
    }
    
    var path: String {
        get {
            switch self {
            case .endpoint1:
                return "test"
            case .endpoint2(let path):
                return path
            }
        }
    }
    
    var baseURL: URL {
        get {
            switch self {
            case .endpoint1 :
                return URL(string: "https://www.netcetera.com")!
            case .endpoint2(path: "example.com") :
                return URL(string: path)!
            default:
                return URL(string: "http://www.example.com")!
            }
        }
    }
    
    var queryParameters: [String : AnyObject] {
        get {
            switch self {
            case .endpoint1:
                return [:]
            default:
                return ["city" : "Zürich" as AnyObject]
            }
        }
    }
    
    var parameters : [String : AnyObject] {
        get {
            switch self {
            case .endpoint1:
                return [:]
            default:
                return ["token" : "aToken" as AnyObject]
            }
        }
    }
    
    var requestGenerator : RequestGenerator {
        get {
            return StandardRequestGenerator()
        }
    }
}
