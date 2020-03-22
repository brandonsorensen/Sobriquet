//
//  StudentFile.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/22/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Foundation

public class StudentFile {
    
    public enum CopyStatus {
        case Uncopied
        case Copied
        case Overwrite
        case NotFound
    }
    
    private var student: Student
    private var path: String
    private var copyStatus: CopyStatus = .Uncopied
    private let fileManager: FileManager = FileManager.default
    
    public init(student: Student, path: String) {
        self.student = student
        self.path = path
        
        if !fileManager.fileExists(atPath: path) { self.copyStatus = .NotFound }
    }
    
    public func renameFile(newPath: String) throws -> CopyStatus {
        // TODO
        if self.copyStatus == CopyStatus.NotFound { throw RenameError.FileNotFoundError }
        return .Uncopied
    }
    
    public func renameFile(newPath: URL) throws -> CopyStatus { return try self.renameFile(newPath: newPath.absoluteString) }
    
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
