//
//  sort-files.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Cocoa
import Foundation
import CoreData

enum PATH_STATUS {
    case SUCCESS
    case NOTADIR
    case NOTEXIST
}

func readCSV(csvURL: String, encoding: String.Encoding, delimiter: String = ",", inBundle: Bool = true) -> [CSVFields]? {
    
    // Load the CSV file and parse it
    var entries = [CSVFields]()
    var lines: [String]
    var fields: [String]

    if let path = Bundle.main.path(forResource: csvURL, ofType: "csv") {
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            lines = data.components(separatedBy: .newlines)
            for line in lines {
                if !line.isEmpty {
                    fields = line.components(separatedBy: delimiter)
                    if fields[0] == "EDUID" { continue }  // Skip header
                    
                    entries.append(
                        CSVFields(
                            eduid: Int(fields[0])!, lastName: fields[1],
                            firstName: fields[2],
                            middleName: fields[3].isEmpty ? nil : fields[3]
                        )
                    )
//                    items.append(student)
                }
            }
            
        } catch {
            print(error)
        }
    }
    return entries
}

public struct CSVFields {
    var eduid: Int,
    lastName: String,
    firstName: String,
    middleName: String?
}

public func addStudent(eduid: Int, lastName: String, firstName: String, middleName: String?) {
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    let student = Student(context: managedObjectContext)
    student.eduid = eduid
    student.lastName = lastName
    student.firstName = firstName
    student.middleName  = middleName
    
    do {
        try managedObjectContext.save()
    } catch {
        fatalError("Failure to save context: \(error)")
    }
}

public func addStudent(entry: CSVFields) {
    return addStudent(eduid: entry.eduid, lastName: entry.lastName,
                      firstName: entry.firstName, middleName: entry.middleName)
}

public class Student: NSManagedObject, Identifiable {
    
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
//        return NSFetchRequest<Student>(entityName: "Student")
//    }

    @NSManaged public var eduid: Int
    @NSManaged public var lastName: String
    @NSManaged public var firstName: String
    @NSManaged public var middleName: String?
    
    static func getAllStudents() -> NSFetchRequest<Student> {
        let request: NSFetchRequest<Student> = NSFetchRequest(entityName: "Student")
        
        let primarySortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        
        request.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        
        return request
    }
}

func renameFile(inputPath: String, outputPath: String) {
    switch checkPath(path: inputPath) {
    case .SUCCESS:
        print("success")
    case .NOTADIR:
        print("not a directory")
    case .NOTEXIST:
        print("does not exist")
    }
}

private func checkPath(path: String) -> PATH_STATUS {
    let fileManager = FileManager.default
    var isDir : ObjCBool = false
    if fileManager.fileExists(atPath: path, isDirectory:&isDir) {
        if isDir.boolValue {
            // file exists and is a directory
            return PATH_STATUS.SUCCESS
        } else {
            // file exists and is not a directory
            return PATH_STATUS.NOTADIR
        }
    } else {
        // file does not exist
        return PATH_STATUS.NOTEXIST
    }
}
