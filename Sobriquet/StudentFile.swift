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
    
    public func renameFile(newPath: String, overwrite: Bool = false) throws -> CopyOperation.CopyStatus {
        let manager = FileManager.default
        
        let url = URL(fileURLWithPath: newPath)
        let baseDir = url.deletingLastPathComponent()
        var isDir: ObjCBool = true
        if !manager.fileExists(atPath: baseDir.path, isDirectory: &isDir) {
            throw CopyOperation.CopyError.BadOutputDir
        }
        
        do {
            if manager.fileExists(atPath: newPath) {
                if overwrite {
                    // TODO: Do actually overwrite.
                    try manager.removeItem(atPath: newPath)
                    return .Overwritten
                } else { throw CopyOperation.CopyError.AlreadyExistsError }
            }
            
            try manager.copyItem(atPath: self.path, toPath: newPath)
            return .Copied
        } catch let e as CopyOperation.CopyError {
            throw e
        } catch {
            print("\(error)")
            throw CopyOperation.CopyError.Unknown
        }
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
}
