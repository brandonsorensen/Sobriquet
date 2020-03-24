//
//  CopyManager.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/23/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Foundation


public struct CopyManager {
    public static let COMPONENT_REGEX = #"%(eduid|last|first|middle)( (name|initial))?%"#
    
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
    
    public mutating func setStatus(at: Int, to: CopyOperation.CopyStatus) {
        self.allOperations[at].setStatus(newStatus: to)
    }
    
    public mutating func updateStatuses(to: CopyOperation.CopyStatus) {
        for operation in allOperations {
            operation.setStatus(newStatus: to)
        }
    }
    
    public static func loadCopyOperations(inputPath: String,
                              outputPath: String,
                              outputFormat: String,
                              studentManager: StudentManager)
        throws -> [CopyOperation] {
            
            if outputFormat.range(of: CopyManager.COMPONENT_REGEX, options: [.regularExpression, .caseInsensitive]) == nil {
            throw CopyOperation.CopyError.NoOutputComponentsError
        }

        var absolutePath: String
        var currentStudentFile: StudentFile
        var currentOperation: CopyOperation
        var operations = [CopyOperation]()
        
        let files = try FileManager.default.contentsOfDirectory(atPath: inputPath)
        var count = 0
        for file in files {
            absolutePath = inputPath + "/" + file
            if let currentStudent = studentManager.getStudentFromFileName(fileName: file) {
                currentStudentFile = StudentFile(student: currentStudent, path: absolutePath)
                currentOperation = try! loadCopyOperation(studentFile: currentStudentFile, outputFormat: outputFormat)

                operations.append(currentOperation)
            }
//            if count > 3 { break }
            count += 1
        }
        
        return operations
    }
}

public class CopyOperation: ObservableObject {
    
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
    
    @Published private var status: CopyStatus = .Pending
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
    
    public func setStatus(newStatus: CopyStatus) {
        self.status = newStatus
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
    
    public static func loadCopyOperation(studentFile: StudentFile, outputFormat: String, outputDir: String) throws -> CopyOperation {
        var returnValue = outputFormat
        let returnOutputDir = outputDir.last == "/" ? outputDir : outputDir + "/"
        var replacementValue: String
        let student = studentFile.getStudent()
        
        for value in ComponentButtonType.allValues {
            replacementValue = try componentStringSwitch(value: value, student: student)
            returnValue = returnValue.replacingOccurrences(of: value, with: replacementValue)
        }
        
        if returnValue == outputFormat {
            // There was no change
            throw CopyOperation.CopyError.NoOutputComponentsError
        }
        
        return CopyOperation(file: studentFile, outputPath: returnOutputDir + returnValue)
    }
}
