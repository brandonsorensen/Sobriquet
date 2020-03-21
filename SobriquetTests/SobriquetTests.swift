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
        let outputFormat = "%Last Name%_%First Name%_%Middle Initial%_test"
        
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        let moc = appDelegate.persistentContainer.viewContext
        
        let students = try! moc.fetch(Student.getAllStudents())
        var studentMap = Dictionary<Int, Student>()
        
        for student in students {
            studentMap[student.eduid] = student
        }
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        renameFilesInDir(inputPath: inputDir, outputPath: outputDir, outputFormat: outputFormat, students: studentMap)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
