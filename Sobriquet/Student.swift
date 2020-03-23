//
//  Student.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/19/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

public func addStudent(eduid: Int, lastName: String, firstName: String, middleName: String?) {
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    let student = Student(context: managedObjectContext)
    student.eduid = eduid
    student.lastName = lastName
    student.firstName = firstName
    student.middleName  = middleName
    student.dateAdded = Date()
    
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

    @NSManaged public var eduid: Int
    @NSManaged public var lastName: String
    @NSManaged public var firstName: String
    @NSManaged public var middleName: String?
    @NSManaged public var dateAdded: Date
    
    static func getAllStudents() -> NSFetchRequest<Student> {
        let request: NSFetchRequest<Student> = NSFetchRequest(entityName: "Student")
        
        let primarySortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        
        request.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        
        return request
    }
    
    static func deleteAllStudents() throws {
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let appDelegate = (NSApplication.shared.delegate) as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        try managedObjectContext.executeAndMergeChanges(using: batchDeleteRequest)
    }
    
    static func getMostRecentDate() -> Date {
        let appDelegate = (NSApplication.shared.delegate) as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        var mostRecent: Date = Date(timeIntervalSince1970: 0)
        
        let request: NSFetchRequest<Student> = NSFetchRequest(entityName: "Student")
        let students = try! moc.fetch(request)
        for student in students {
            mostRecent = max(student.dateAdded, mostRecent)
        }
        return mostRecent
    }
}

public struct StudentManager {
    private var allStudents: [Student]
    private var eduid2StudentIndex: Dictionary<Int, Int>
    
    public var count: Int { return allStudents.count }
    public var isEmpty: Bool { return allStudents.isEmpty }
    
    public init() {
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            allStudents = try moc.fetch(Student.getAllStudents())
        } catch {
            allStudents = [Student]()
        }
            eduid2StudentIndex = StudentManager.getMapFromStudents(students: allStudents)
    }
    
    public init(students: [Student]) {
        allStudents = students
        eduid2StudentIndex = StudentManager.getMapFromStudents(students: students)
    }
    
    public func getStudentFromFileName(fileName: String) -> Student? {
        if let eduid: Int = StudentManager.getEduidFromString(s: fileName) {
            return getStudentForEduid(eduid: eduid)
        }
        return nil
    }
    
    public static func getEduidFromString(s: String) -> Int? {
        if let eduidRange = s.range(of: #"[0-9]{7,9}"#, options: .regularExpression) {
            return Int(s[eduidRange])
        }
        return nil
    }
    
    public func getStudentForEduid(eduid: Int) -> Student? {
        if let eduid = eduid2StudentIndex[eduid] {
            return allStudents[eduid]
        }
        return nil
    }
    
    public mutating func addStudent(student: Student) {
        allStudents.append(student)
        eduid2StudentIndex[student.eduid] = self.count - 1
    }
    
    public mutating func update(students: [Student]) {
        allStudents = students
        eduid2StudentIndex = StudentManager.getMapFromStudents(students: students)
    }
    
    public func getAllStudents() -> [Student] {
        return allStudents
    }
    
    private static func getMapFromStudents(students: [Student]) -> Dictionary<Int, Int> {
        var map = Dictionary<Int, Int>()
        for (index, student) in students.enumerated() {
            map[student.eduid] = index
        }
        return map
    }
}
