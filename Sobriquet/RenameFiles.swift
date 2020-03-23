//
//  sort-files.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Cocoa
import Foundation

func renameFilesInDir(inputPath: String, outputPath: String, outputFormat: String,
                      students: Dictionary<Int, Student>) {
    let start = DispatchTime.now()
    let eduidRegex = try! NSRegularExpression(pattern: "[0-9]{7,9}")
    let regex = try! NSRegularExpression(pattern: "%(eduid|last|first|middle)( (name|initial))?%")
    
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: inputPath)
        var count = 0
        for file in files {
            if count > 3 { break }
            let result = eduidRegex.firstMatch(in: file, range: NSRange(location: 0, length: file.utf16.count))
            let eduid = result.map {
                Int(String(file[Range($0.range, in: file)!]))}!!
            do {
                try renameFile(inputPath: inputPath, outputPath: outputPath,
                outputFormat: outputFormat, student: students[eduid]!)
            } catch RenameError.NoOutputComponentError {
                // TODO
            } catch {
                // TODO
            }
            
            
            count += 1
        }
    } catch {
        print(error)
    }
    
    let interval = DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds
    print(interval / 1_000_000)
}

func renameFile(inputPath: String, outputPath: String, outputFormat: String,
                student: Student) throws {
    
    var returnValue = outputFormat
    var replacementValue: String
    
    for value in ComponentButtonType.allValues {
        replacementValue = try componentStringSwitch(value: value, student: student)
        returnValue = returnValue.replacingOccurrences(of: value, with: replacementValue)
    }
    
    if returnValue == outputFormat {
        // There was no change
        throw RenameError.NoOutputComponentError
    }
    
    if !outputFormat.hasSuffix(".pdf") { returnValue += ".pdf" }
    print("Before: \(outputFormat)")
    print("Output: \(outputPath)/\(returnValue)")
}

func loadCopyOperations(inputPath: String,
                          outputPath: String,
                          outputFormat: String,
                          studentManager: StudentManager)
    throws -> [CopyOperation] {
        
    if outputFormat.range(of: CopyManager.COMPONENT_REGEX, options: .regularExpression) == nil {
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
        if count > 3 { break }
        count += 1
    }
    
    return operations
}

func loadCopyOperation(studentFile: StudentFile, outputFormat: String) throws -> CopyOperation {
    var returnValue = outputFormat
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
    
    return CopyOperation(file: studentFile, outputPath: returnValue)
}

func componentStringSwitch(value: String, student: Student) throws -> String {
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
        throw RenameError.ComponentIterationError
    }
    
    return replacementValue
}

enum RenameError: Error {
    case NoOutputComponentError
    case UnknownOutputComponentError
    case RepeatedComponentError
    case ComponentIterationError
    case FileNotFoundError
}
