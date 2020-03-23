//
//  CopyManager.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/23/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Foundation


public struct CopyManager {
    private var allOperations: [CopyOperation]
    
    public func executeAll() {
        for operation in allOperations {
            let _ = operation.execute()
        }
    }
}

public class CopyOperation {
    
    public enum CopyStatus {
        case Copied
        case Overwritten
        case AlreadyExists
        case Pending
        case Unsuccessful
    }
    
    public enum CopyError: Error {
        case AlreadyExistsError
    }
    
    private var status: CopyStatus = .Pending
    private var file: StudentFile
    private var outputPath: String

    public init(file: StudentFile, outputPath: String) {
        self.file = file
        self.outputPath = outputPath
    }
    
    public convenience init(file: StudentFile, status: CopyStatus, outputPath: String) {
        self.init(file: file, outputPath: outputPath)
        self.status = status
    }
    
    public func execute() -> CopyStatus {
        do {
            self.status = try self.file.renameFile(newPath: outputPath)
        } catch CopyError.AlreadyExistsError {
            self.status = .AlreadyExists
        } catch {
            self.status = .Unsuccessful
        }
        return self.status
    }
    
    public func getStatus() -> CopyStatus {
        return self.status
    }
    
    public func getStudentFile() -> StudentFile {
        return self.file
    }
    
    public func setStudentFile(newFile: StudentFile) {
        self.file = newFile
    }
    
    public func getOutputPath() -> String {
        return self.outputPath
    }
    
    public func setOutputPath(newPath: String) {
        self.outputPath = newPath
    }
    
    public func setOutputPath(newPath: URL) {
        self.setOutputPath(newPath: newPath.absoluteString)
    }
}
