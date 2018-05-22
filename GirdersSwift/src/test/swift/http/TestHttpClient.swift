//
//  TestHttpClient.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 05.09.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
import UIKit
@testable import GirdersSwift

class TestHttpClient: XCTestCase {
    var httpClient: HTTPClient!
    let mockSession: MockURLSession = MockURLSession()
    let session = URLSession(configuration: .default)
    
    override func setUp() {
        super.setUp()
        let mockResponseHandler = MockResponseHandler()
        httpClient = HTTPClient(urlSession: session, handlers: [mockResponseHandler])
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThatHttpClientExecutesGetWithUrl() {
        //let urlPath = testBundle.url(forResource: "billTest", withExtension: "jpg")
        let urlPath = URL(string: "https://google.com")
        let request = Request(URL: urlPath!, method: HTTPMethod.GET)
        
        let result: GirdersSwift.Result<Response<String>, Error?> = httpClient.executeRequest(request: request)
        
        XCTAssertNotNil(result)
    }
    
    func testClientWitUrl() {
        let url = URL(string: "https://google.com")
        
        let response: Result<Response<Data>, Error?> = httpClient.get(url: url!)
        
        switch response {
        case .Success(let response):
            XCTAssertNotNil(response)
        case .Failure(let error):
            XCTAssertNil(error)
        }
    }
    
    func testThatRequestWithResponseHandlerRetrurnsBodyObject() {
        let url = URL(string: "https://httpbin.org/get")!

        let result: Result<Response<String>, Error?> = httpClient.get(url: url)
        switch result {
        case .Success(let response):
            XCTAssertNotNil(response.bodyObject)
        case .Failure(let error):
            XCTAssertNil(error)
        }
        XCTAssertNotNil(result)
    }
    
    func testThatRequestReturnsBody() {
        let url = URL(string: "https://httpbin.org/get")!

        let response: Result<Response<Data>, Error?> = httpClient.get(url: url)
        
        switch response {
        case .Success(let response):
            XCTAssertNotNil(response.body)
        case .Failure(let error):
            XCTAssertNil(error)
        }
    }

}


class MockURLSessionDataTask {
    private (set) var resumeWasCalled = false
    func resume() {
        resumeWasCalled = true
    }
}

class MockURLSession {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextError: Error?
    
    private (set) var lastURL: URL?
    
    func successHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> MockURLSessionDataTask {
        lastURL = request.url
        
        completionHandler(nextData, successHttpURLResponse(request: request), nextError)
        return nextDataTask
    }
}

class MockResponseHandler: ResponseHandler {
    func canHandle<T>(responseType: T) -> Bool {
        return type(of: responseType) == type(of: String.self)
    }
    func process<T>(responseData: Data) -> T? {
        return String(data: responseData, encoding: .utf8) as? T
    }
}


