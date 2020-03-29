//
//  StudentFile.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/22/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Foundation
import SwiftUI

public class StudentFile {
    
    private var student: Student
    private var path: String
    private var exists: Bool { return FileManager.default.fileExists(atPath: path) }
    public static let eduidRegex = #"[0-9]{9}"#
    
    public enum StudentFileError: Error {
        case BadOutputDir
        case NoEduidInPath
        case NoStudentFound
        case UnknownCopyError
    }
    
    public init(student: Student, path: String) {
        self.student = student
        self.path = path
    }
    
    public convenience init(path: String) throws {
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        let moc = appDelegate.persistentContainer.viewContext
        var eduid: Int
        
        if let result = path.range(of: StudentFile.eduidRegex, options: .regularExpression) {
            eduid = Int(String(path[result]))!
        } else {
            throw StudentFileError.NoEduidInPath
        }
        
        let allStudents = try moc.fetch(Student.getAllStudents())
        for student in allStudents {
            if student.eduid == eduid {
                self.init(student: student, path: path)
                return
            }
        }
        
        throw StudentFileError.NoStudentFound
    }
    
    public func setStudent(newStudent: Student) {
        self.student = newStudent
    }
    
    public func getStudent() -> Student {
        return self.student
    }
    
    public func setPath(newPath: String) {
        self.path = newPath
    }
    
    public func getPath() -> String {
        return self.path
    }
}

public class UnknownFile: StudentFile {
    public static let unknownStudent = initUnknownStudent()
    
    public init(path: String) {
        super.init(student: UnknownFile.unknownStudent, path: path)
    }
    
    private static func initUnknownStudent() -> Student {
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        let moc = appDelegate.persistentContainer.viewContext
        let student = Student(context: moc)
        
        student.firstName = ""
        student.lastName = ""
        student.eduid = 0
        student.dateAdded = Date()
        
        return student
    }
}
