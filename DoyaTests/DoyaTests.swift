//
//  DoyaTests.swift
//  DoyaTests
//
//  Created by vortispy on 2014/08/10.
//  Copyright (c) 2014年 vortispy. All rights reserved.
//

import UIKit
import XCTest

class DoyaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
        
        let redis = DSRedis(server:"localhost", port:6379, password: nil)
        XCTAssertTrue(redis.ping())
    }
    
    
    func testConvertImage() {
        let bundle = NSBundle(forClass: DoyaTests.self)
        let url = bundle.URLForResource("sample", withExtension: "jpg")
        XCTAssertNotNil(url)
        
        let image = UIImage(contentsOfFile: url.path)
        XCTAssertNotNil(image)
        
        var data : NSData
        var quality = 1.0 as CGFloat
        do {
            quality -= 0.1
            data = UIImageJPEGRepresentation(image, quality)
        } while (data.length < 10000)
        XCTAssertNotNil(data)
//        XCTAssertTrue(data.length < 10000)
        
        let width = 100 as CGFloat
        let height = 100 as CGFloat
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
        image.drawInRect(CGRectMake(0,0,width,height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        XCTAssertNotNil(newImage)
        XCTAssertEqual(newImage.size.width, width)
        XCTAssertEqual(newImage.size.height, height)
    }
    
    func testUpload() {
        let bundle = NSBundle(forClass: DoyaTests.self)
        let url = bundle.URLForResource("sample", withExtension: "jpg")
        XCTAssertNotNil(url)

        let image = UIImage(contentsOfFile: url.path)
        XCTAssertNotNil(image)
        
        let data = UIImageJPEGRepresentation(image, 1.0)

        let requestURL = NSURL(string: "http://ds-s3-uploader.herokuapp.com/upload")
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "POST"
        let session = NSURLSession.sharedSession()
        let queue = session.delegateQueue
        let task = session.uploadTaskWithRequest(request, fromData: data) { (resData, response, error) -> Void in
            println("!!!!!!!!!!!")
            println(response)
        }
        task.resume()
        
        queue.waitUntilAllOperationsAreFinished()
        NSThread.sleepForTimeInterval(3)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
