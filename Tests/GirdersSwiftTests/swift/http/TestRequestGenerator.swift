//
//  TestRequest.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 16.08.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestRequestGenerator: XCTestCase { }

//TODO: test with local url (url for resource from path

class TestStandardRequestGenerator: XCTestCase {
    
    let mockGenerator = TestMockRequestGenerator()
    
    func testStandardRequestWithMethodAlwaysReturnsRequest() {
        XCTAssertNotNil(mockGenerator.request(withMethod: HTTPMethod.GET))
    }
    
    func testWithBasicAuth_returnsRequestWithAuthorization_whenUsernamePasswordAreConfigured() {
        //Given
        let authorizationParam = "Authorization"
        let mutableRequest = MutableRequest(method: HTTPMethod.GET)
        XCTAssertNil(mutableRequest.headerFields[authorizationParam])
        
        //When
        // Configuration plists not found due different bundle in Testing environment.
        let authorizedRequest = mockGenerator.withBasicAuth(request: mutableRequest)
        
        //Then
        XCTAssertNotNil(authorizedRequest.headerFields[authorizationParam])
    }
    
    // Not implemented yet since we are using static Singleton for Configuration
    func testWithBasicAuth_returnsProvidedRequest_whenUsernamePasswordNotConfigured() {}
    
    func testWithJsonSupport_returnsRequestWithJsonParam() {
        //Given
        let acceptParam = "Accept"
        let mutableRequest = MutableRequest(method: HTTPMethod.GET)
        XCTAssertNil(mutableRequest.headerFields[acceptParam])
        
        //When
        let jsonRequest = mockGenerator.withJsonSupport(request: mutableRequest)
        
        //Then
        XCTAssertEqual("application/json", jsonRequest.headerFields[acceptParam])
    }
    
    func testGenerateRequest_returnsMutableRequestWithJsonSupport() {
        //Given
        let acceptParam = "Accept"
        let httpMethod = HTTPMethod.GET
        
        //When
        let generateRequest = mockGenerator.generateRequest(withMethod: httpMethod)
        
        //Then
        XCTAssertEqual(httpMethod, generateRequest.method)
        XCTAssertEqual("application/json", generateRequest.headerFields[acceptParam])
    }
    
    func testThatGetConfigurationReturnsConfiguration() {
        XCTAssertNotNil(mockGenerator.getConfiguration())
    }
    
}

class TestMockRequestGenerator: RequestGenerator {
    
    public func getConfiguration() -> Configuration {
        return Configuration(bundle: Bundle(for: TestConfiguration.self))
    }
    
    public func withBasicAuth(request: MutableRequest) -> MutableRequest {
        var request = request
        let username = getConfiguration()["auth.username"] as? String
        let password = getConfiguration()["auth.password"] as? String
        if let username = username, let password = password {
            let authorizationString = "\(username):\(password)"
            if let authorizationData = authorizationString.data(using: String.Encoding.utf8) {
                let base64Data =
                    authorizationData.base64EncodedData()
                let authorization = "Basic \(base64Data)"
                let authorizationHeader = ["Authorization" : authorization]
                request.updateHTTPHeaderFields(headerFields: authorizationHeader)
            }
        }
        
        return request
    }
}

class TestMutableRequest: XCTestCase {
    
    let mockGenerator = TestMockRequestGenerator()

    func testUpdateParameters() {
        var request = mockGenerator.generateRequest(withMethod: .POST)
        let additionalParameters = ["TestParam": MockClass()]
        
        request.updateParameters(parameters: additionalParameters)
        
        XCTAssertNotNil(request.parameters)
    }
    
    func testupdateHTTPHeaderFields() {
        var request = mockGenerator.request(withMethod: .POST) |> mockGenerator.withBasicAuth |> mockGenerator.withJsonSupport
        
        XCTAssertEqual(request.headerFields["Accept"], "application/json")
        XCTAssertNotNil(request.headerFields["Authorization"])
        
        let additionalHeaderFields = ["Test1" : "123", "Test2" : "1337"]
        
        request.updateHTTPHeaderFields(headerFields: additionalHeaderFields)
        
        XCTAssertNotNil(request.headerFields["Test1"])
    }
}
