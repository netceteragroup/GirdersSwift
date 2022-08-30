//
//  TestContainer.swift
//  UnitTest
//
//  Created by Zdravko Nikolovski on 5/31/18.
//  Copyright © 2018 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestContainer: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        Container.cleanup()
        super.tearDown()
    }
    
    func testThatAddSingletonRegistersASingletonProtocolSuccessfully() {
        // When
        Container.addSingleton { () -> TestContainerProtocol in
            return TestContainerClass()
        }
        
        // Then
        let resolved1: TestContainerProtocol = Container.resolve()
        let resolved2: TestContainerProtocol = Container.resolve()
        
        XCTAssert(resolved1 === resolved2)
        XCTAssertEqual(resolved1.getValue(), resolved2.getValue())
    }
    
    func testThatAddPerRequestRegistersASingletonProtocolSuccessfully() {
        // When
        Container.addPerRequest { () -> TestContainerProtocol in
            return TestContainerClass()
        }
        
        // Then
        let resolved1: TestContainerProtocol = Container.resolve()
        let resolved2: TestContainerProtocol = Container.resolve()
        
        XCTAssert(resolved1 !== resolved2)
        XCTAssertNotEqual(resolved1.getValue(), resolved2.getValue())
    }
    
    func testThatAddSingletonRegistersASingletonClassSuccessfully() {
        // When
        Container.addSingleton { () -> TestContainerClass in
            return TestContainerClass()
        }
        
        // Then
        let resolved1: TestContainerClass = Container.resolve()
        let resolved2: TestContainerClass = Container.resolve()
        
        XCTAssert(resolved1 === resolved2)
        XCTAssertEqual(resolved1.getValue(), resolved2.getValue())
    }
    
    func testThatAddPerRequestRegistersASingletonClassSuccessfully() {
        // When
        Container.addPerRequest { () -> TestContainerClass in
            return TestContainerClass()
        }
        
        // Then
        let resolved1: TestContainerClass = Container.resolve()
        let resolved2: TestContainerClass = Container.resolve()
        
        XCTAssert(resolved1 !== resolved2)
        XCTAssertNotEqual(resolved1.getValue(), resolved2.getValue())
    }
    
}

// MARK:- Test protocols and classes
protocol TestContainerProtocol: class {
    func getValue() -> String
}

class TestContainerClass: TestContainerProtocol {
    var value = UUID().uuidString
    
    func getValue() -> String {
        return value
    }
}
