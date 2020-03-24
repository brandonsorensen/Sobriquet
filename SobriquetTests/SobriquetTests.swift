//
//  SobriquetTests.swift
//  SobriquetTests
//
//  Created by Brandon Sorensen on 3/19/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import XCTest
@testable import Sobriquet

class SobriquetTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let baseDir = "/Users/Brandon/Library/Mobile Documents/com~apple~CloudDocs/Programming/Projects/Sobriquet/"
        let inputDir = baseDir + "test-files"
        let outputDir = baseDir + "test-output"
        let outputFormat = "%Last Name%_%First Name%_%Last Name%_test"
        
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        let moc = appDelegate.persistentContainer.viewContext
        
        let app = XCUIApplication()
        app.textFields["Enter path to files."].typeText(outputDir)
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
