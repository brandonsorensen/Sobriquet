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
    
    public func filter(by: CopyOperation.CopyStatus?, exclude: Bool = false) -> [Int] {
        if by == nil {
            return Array(0..<allOperations.count)
        }
        
        var addIndex: Bool
        var status: CopyOperation.CopyStatus
        var returnIndices = [Int]()
        for (i, operation) in allOperations.enumerated() {
            status = operation.getStatus()
            addIndex = exclude ? status != by : status == by
            if addIndex { returnIndices.append(i) }
        }
        return returnIndices
    }
    
    public func filter(by: [CopyOperation.CopyStatus]) -> [Int] {
        var returnIndices = [Int]()
        var status: CopyOperation.CopyStatus
        
        for (i, operation) in allOperations.enumerated() {
            status = operation.getStatus()
            for filter in by {
                if status == filter {
                    returnIndices.append(i)
                    break
                }
            }
        }
        return returnIndices
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
                              studentManager: StudentManager,
                              inFileName: Bool = false)
        throws -> [CopyOperation] {
            
        if outputFormat.range(of: CopyManager.COMPONENT_REGEX, options: [.regularExpression, .caseInsensitive]) == nil {
            throw CopyOperation.CopyError.NoOutputComponentsError
        }

        var absolutePath: String
        var currentStudent: Student?
        var currentStudentFile: StudentFile
        var currentOperation: CopyOperation
        var operations = [CopyOperation]()
        let files: [String]?
        
        do {
            files = try FileManager.default.contentsOfDirectory(atPath: inputPath)
        } catch {
            throw CopyOperation.CopyError.BadInputDir
        }
            
        for file in files! {
            absolutePath = inputPath + "/" + file
            if inFileName {
                currentStudent = studentManager.getStudentFromFileName(fileName: absolutePath)
            } else {
                currentStudent = studentManager.getStudentFromFileContents(fileName: absolutePath)
            }
            
            if currentStudent != nil {
                currentStudentFile = StudentFile(student: currentStudent!, path: absolutePath)
                currentOperation = try! CopyOperation.loadCopyOperation(studentFile: currentStudentFile,
                                                                        outputFormat: outputFormat,
                                                                        outputDir: outputPath)
            } else {
                currentStudentFile = UnknownFile(path: absolutePath)
                currentOperation = try! CopyOperation.loadCopyOperation(studentFile: currentStudentFile,
                                                                        outputFormat: outputFormat,
                                                                        outputDir: "N/A")
                currentOperation.setStatus(newStatus: .StudentUnknown)
            }
            operations.append(currentOperation)
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
        case StudentUnknown
    }
    
    public enum CopyError: Error {
        case BadInputDir
        case BadOutputDir
        case ComponentIterationError
        case AlreadyExistsError
        case NoOutputComponentsError
        case UnknownStudentError
        case Unknown
    }
    
    @Published private var status: CopyStatus = .Pending
    private var file: StudentFile
    private var outputPath: String

    public init(file: StudentFile, outputPath: String) {
        self.file = file
        let pathAsUrl = URL(string: outputPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        var basename = pathAsUrl.deletingPathExtension().lastPathComponent
        // Remove all non-word characters (excluding underscores)
        basename = basename.replacingOccurrences(of: #"[^\w]"#, with: "",
                                                 options: [.regularExpression])
        // Remove duplicate underscores
        basename = basename.replacingOccurrences(of: #"_{2,}"#, with: "_",
                                                 options: [.regularExpression])
        self.outputPath = (pathAsUrl.deletingLastPathComponent()
                            .appendingPathComponent(basename)
                            .absoluteString + "." + pathAsUrl.pathExtension)
    }
    
    public convenience init(file: StudentFile, status: CopyStatus, outputPath: String) {
        self.init(file: file, outputPath: outputPath)
        self.status = status
    }
    
    public func execute(overwrite: Bool = false) -> CopyStatus {
        do {
            self.status = try self.renameFile(newPath: outputPath, overwrite: overwrite)
        } catch CopyOperation.CopyError.AlreadyExistsError {
            self.status = .AlreadyExists
        } catch CopyOperation.CopyError.UnknownStudentError {
            self.status = .StudentUnknown
        } catch {
            self.status = .Unsuccessful
        }
        return self.status
    }
    
    private func renameFile(newPath: String, overwrite: Bool) throws -> CopyStatus {
        if self.status == .StudentUnknown {
            throw CopyError.UnknownStudentError
        }
        
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
                    try manager.removeItem(atPath: newPath)
                    return .Overwritten
                } else { throw CopyOperation.CopyError.AlreadyExistsError }
            }
            
            try manager.copyItem(atPath: self.file.getPath(), toPath: newPath)
            self.file.setPath(newPath: newPath)
            return .Copied
        } catch let e as CopyOperation.CopyError {
            throw e
        } catch {
            throw CopyOperation.CopyError.Unknown
        }
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
    
    public static func componentStringSwitch(value: String, student: Student) throws -> String {
        // TODO: Why does lowercase EDUID not work?
        var replacementValue: String = ""
        
        switch value.lowercased() {
        case "%eduid%":
            replacementValue = String(student.eduid)
        case "%first name%":
            replacementValue = student.firstName
        case "%last name%":
            replacementValue = student.lastName
        case "%middle name%":
            if let middle = student.middleName {
                replacementValue = middle
            }
        case "%middle initial%":
            if let middle = student.middleName {
                if !middle.isEmpty {
                    replacementValue = String(middle.first!)
                }
            }
        default:
            throw CopyError.ComponentIterationError
        }
        
        return replacementValue
    }
    
    public static func loadCopyOperation(studentFile: StudentFile, outputFormat: String, outputDir: String) throws -> CopyOperation {
        var returnValue = outputFormat
        let returnOutputDir = outputDir.last == "/" ? outputDir : outputDir + "/"
        var replacementValue: String
        let student = studentFile.getStudent()
        
        for value in ComponentButtonType.allValues {
            replacementValue = try componentStringSwitch(value: value, student: student)
            returnValue = returnValue.replacingOccurrences(of: value, with: replacementValue, options: .caseInsensitive)
        }
        
        if returnValue == outputFormat {
            // There was no change
            throw CopyOperation.CopyError.NoOutputComponentsError
        }
        
        return CopyOperation(file: studentFile, outputPath: returnOutputDir + returnValue)
    }
}
