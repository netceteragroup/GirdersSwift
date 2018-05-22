//
//  DateStringUtils.swift
//  UnitTest
//
//  Created by Angjel Kichukov on 17.08.17.
//  Copyright © 2017 Netcetera AG. All rights reserved.
//

import XCTest
@testable import GirdersSwift

class TestDateStringUtils: XCTestCase {
    
    //Test Date - Thursday, 9 May 2002 15:21:00 GMT
    var sampleDate: Date?
    let epoch = 1020957660
    let rfc822 = "Thu, 09 May 2002 15:21:00 GMT"
    let rfc3339 = "2002-05-09T15:21:00Z"
    
    override func setUp() {
        super.setUp()
        sampleDate = Date(timeIntervalSince1970: TimeInterval(exactly: epoch)!)
    }
    
    override func tearDown() {
        sampleDate = nil
        super.tearDown()
    }
    
    func testThatParseRFC822ReturnExpectedDate() {
        var timestamp = "Sun, 9 May 2002 15:21:00 GMT"
        var parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "Sun, 09 May 2002 15:21:00 GMT"
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "Sun, 9 May 2002 15:21 GMT"
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "Sun, 09 May 2002 15:21 GMT"
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "Sun, 9 May 2002 15:21:00"
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "Sun, 09 May 2002 15:21:00"
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "Sun, 9 May 2002 15:21"
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "Sun, 09 May 2002 15:21"
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "9 May 2002 15:21:00 GMT";
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "9 May 2002 15:21 GMT"
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "9 May 2002 15:21:00";
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
        timestamp = "9 May 2002 15:21"
        parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertEqual(sampleDate, parsedDate)
        
    }
    
    func testThatParseRFC822TimeStamReturnsNilOnIncorectString() {
        let stringSample = "Invalid String Sample"
        let dateValue = stringSample.parseRFC822Timestamp()
        
        XCTAssertNil(dateValue)
    }
    
    func testThatParseRFC822TimeStampRetunsNullOnIncorectTimeStamp() {
        let timestamp = "1996-12-19T16:39:57-0800"
        let parsedDate = timestamp.parseRFC822Timestamp()
        XCTAssertNil(parsedDate)
    }
    
    func testThatParseRFC822TimeStampReturnsNilForEmptyString() {
        let timestamp = ""
        let parseDate = timestamp.parseRFC822Timestamp()
        XCTAssertNil(parseDate)
    }
    
    func testThatParseRFC3339TimeStampReturnsExpectedDate() {
        var timestamp = "2002-05-09T15:21:00-0000"
        var parsedDate = timestamp.parseRFC3339Timestamp()

        timestamp = "2002-05-09T15:21:00+0000"
        parsedDate = timestamp.parseRFC3339Timestamp()

        timestamp = "2002-05-09T15:21:00.00-0000"
        parsedDate = timestamp.parseRFC3339Timestamp()
    
        timestamp = "2002-05-09T15:21:00"
        parsedDate = timestamp.parseRFC3339Timestamp()
        
        XCTAssertNotNil(parsedDate)
    }
    
    func testThatParseRFC3339TimeStampReturnsNilOnEmptyString() {
        let timestamp = ""
        let parsedDate = timestamp.parseRFC3339Timestamp()
        XCTAssertNil(parsedDate)
        
    }
    
    func testThatParseRFC3339TimeStamReturnsNilOnIncorectString() {
        let stringSample = "Invalid String Sample"
        let dateValue = stringSample.parseRFC3339Timestamp()
        XCTAssertNil(dateValue)
    }
    
    func testThatParseRFC3339TimeStampReturnsNilOnIncorectTimeStamp(){
        let timestamp = "9 May 2002 15:21"
        let parsedDate = timestamp.parseRFC3339Timestamp();
        XCTAssertNil(parsedDate)
    }

    func testThatToRFC822StringRetunsExpectedTimeStamp() {
        let timeStamp822 = sampleDate?.toRFC822String()
        XCTAssertEqual(rfc822, timeStamp822)
    }
    
    func testThatToRFC3339StringReturnsExpectedTimeStamp() {
        let timeStamp3339 = sampleDate?.toRFC3339String()
        XCTAssertEqual(rfc3339, timeStamp3339)
    }
}
