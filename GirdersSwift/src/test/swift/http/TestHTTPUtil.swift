//
//  TestHTTPUtil.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 16.08.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

//TODO: split in separate files
class TestHTTPUtil: XCTestCase {
    
    //TODO: Test pipe
    func testThatPipeOperatorWorksAsExpected() {
        func square(n: Int) -> Int {
            return n * n
        }
        
        func increment(n: Int) -> Int {
            return n + 1
        }
        
        let value: Int? = 1;
        let tmp = value! |> increment |> square
        
        XCTAssertEqual(4, tmp)
    }
    
    func testPlusEquals_extendsDictionary_whenKeysNotMatch() {
        var firstDictionary = [Int: String]()
        firstDictionary[1] = "val 1"
        firstDictionary[2] = "val 2"
        
        var secondDictionary = [Int: String]()
        secondDictionary[3] = "Three"
        
        firstDictionary+=secondDictionary
        XCTAssertEqual("val 1", firstDictionary[1])
        XCTAssertEqual("val 2", firstDictionary[2])
        XCTAssertEqual("Three", firstDictionary[3])
    }
    
    /// Test for += method
    func testPlusEquals_overwritesDictionaryValues_whenKeysIntersecting() {
        var firstDictionary = [Int: String]()
        firstDictionary[1] = "val 1"
        firstDictionary[2] = "val 2"
        firstDictionary[3] = "val 3"
        
        var secondDictionary = [Int: String]()
        secondDictionary[2] = "Two"
        secondDictionary[3] = nil
        
        firstDictionary+=secondDictionary
        XCTAssertEqual("val 1", firstDictionary[1])
        XCTAssertEqual("Two", firstDictionary[2])
    }
    
    /// Test for += method
    func testPlusEquals_ignoresNils_whenMerging() {
        var firstDictionary = [Int: String]()
        firstDictionary[1] = "val 1"
        firstDictionary[2] = "val 2"
        
        var secondDictionary = [Int: String]()
        secondDictionary[2] = nil
        
        firstDictionary+=secondDictionary
        XCTAssertEqual("val 1", firstDictionary[1])
        XCTAssertEqual("val 2", firstDictionary[2])
    }
    
}

