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
    private var exists: Bool
    private var copyStatus: CopyOperation.CopyStatus = .Pending
    
    public enum StudentFileError: Error {
        case NoEduidInPath
        case NoStudentFound
    }
    
    public init(student: Student, path: String) {
        self.student = student
        self.path = path
        self.exists = !FileManager.default.fileExists(atPath: path)
    }
    
    public convenience init(path: String) throws {
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        let moc = appDelegate.persistentContainer.viewContext
        var eduid: Int
        
        let eduidRegex = #"[0-9]{7,9}"#
        
        if let result = path.range(of: eduidRegex, options: .regularExpression) {
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
    
    public func renameFile(newPath: String) throws -> CopyOperation.CopyStatus {
        // TODO
        return .Copied
    }
    
    public func renameFile(newPath: URL) throws -> CopyOperation.CopyStatus { return try self.renameFile(newPath: newPath.absoluteString) }
    
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
    
    public func setCopyStatus(newCopyStatus: CopyStatus) {
        self.copyStatus = newCopyStatus
    }
    
    public func getCopyStatus() -> CopyStatus {
        return self.copyStatus
    }
}
