//
//  CopyManager.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/23/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Foundation


public struct CopyManager {
    public static let COMPONENT_REGEX = "%(eduid|last|first|middle)( (name|initial))?%"
    
    private var allOperations = [CopyOperation]()
    
    
    public mutating func addFromDirectory(inputPath: String,
                                          studentMap: Dictionary<Int, Student>) {
        
        
    }
    
    public func countSuccessful() -> Int {
        var count = 0
        var status: CopyOperation.CopyStatus
        
        for operation in allOperations {
            status = operation.getStatus()
            if status == .Copied || status == .Overwritten {
                count += 1
            }
        }
        return count
    }
    
    public func countFailed() -> Int {
        var count = 0
        var status: CopyOperation.CopyStatus
         
        for operation in allOperations {
            status = operation.getStatus()
            if status == .Unsuccessful || status == .AlreadyExists {
                count += 1
            }
        }
        return count
    }
    
    public func countPending() -> Int {
        var count = 0
        var status: CopyOperation.CopyStatus
         
        for operation in allOperations {
            status = operation.getStatus()
            if status == .Pending {
                count += 1
            }
        }
        return count
    }

    public var isEmpty: Bool { return allOperations.isEmpty }
    
    public var count: Int { return allOperations.count }
    
    public func getOperation(at: Int) -> CopyOperation {
        return self.allOperations[at]
    }
    
    public func getAllOperations() -> [CopyOperation] {
        return self.allOperations
    }
    
    public mutating func setOperationList(operations: [CopyOperation]) {
        allOperations = operations
    }
    
    public mutating func update(operations: [CopyOperation]) {
        setOperationList(operations: operations)
    }
    
    public mutating func addOperation(op: CopyOperation) {
        allOperations.append(op)
    }
    
    public mutating func clearAll() {
        allOperations.removeAll()
    }
    
    public func executeAll() {
        for operation in allOperations {
            let _ = operation.execute()
        }
    }
    
    public static func operationsFromStudentFiles(files: [StudentFile], outputFormat: String, outputDir: String) -> [CopyOperation] {
        return [CopyOperation]()
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
        case NoOutputComponentsError
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
