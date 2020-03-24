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

/// Creates a `Student` object and saves it to Core Data persistent storage.
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

/// Creates a `Student` object and saves it to Core Data persistent storage.
public func addStudent(entry: CSVFields) {
    return addStudent(eduid: entry.eduid, lastName: entry.lastName,
                      firstName: entry.firstName, middleName: entry.middleName)
}


/**
 👨🏻‍🎓 A student object in the data base.
 
 - Parameters:
    - eduid: tnique student identifying ID
    - lastName: the student's surname
    - firstName: the student's given name
    - middleName: the student's middle name
    - dateAdded: the date the student was added to the data base
 */
public class Student: NSManagedObject, Identifiable {

    @NSManaged public var eduid: Int
    @NSManaged public var lastName: String
    @NSManaged public var firstName: String
    @NSManaged public var middleName: String?
    @NSManaged public var dateAdded: Date
    
    /**
     Creates a fetch request for every student in the data base sorted by their
     first and then last name.
     
     - Returns: A n `NSFetchRequest` for all students in the data base.
     */
    static func getAllStudents() -> NSFetchRequest<Student> {
        let request: NSFetchRequest<Student> = NSFetchRequest(entityName: "Student")
        
        let primarySortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        
        request.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        
        return request
    }
    
    /**
        Deletes all the students in the data base.
     
     - Throws: An error if anything went wrong executing the batch deletion
     */
    static func deleteAllStudents() throws {
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let appDelegate = (NSApplication.shared.delegate) as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        try managedObjectContext.executeAndMergeChanges(using: batchDeleteRequest)
    }
    
    /**
     Gets the time at which the last student was submitted to the data base.
     
     - Returns: A `Date` object represents the most recent commit to the data base
     */
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


/// A struct that facilitates the creation and management of `Student` objects.
public struct StudentManager {
    
    /// Errors that may occur in the creation or management of `Students`.
    public enum StudentManagerError: Error {
        /// Two or more of the students have the same EDUID.
        case NonUniqueElementError
    }
    
    /// A list of all the students
    private var allStudents: [Student]
    
    /// A map of all student EDUIDs to their respective students' indices in `allStudents`
    private var eduid2StudentIndex: Dictionary<Int, Int>
    
    /// Returns the nuber of students
    public var count: Int { return allStudents.count }
    
    /// Whether there are any students
    public var isEmpty: Bool { return allStudents.isEmpty }
    
    /**
     Initializes a new `StudentManager` object by fetching all `Student`s from
     Core Data persistent storage.
     
     - Throws:
        - Any error resulting from `managedObjectContext.fetch`.
        - `StudentManagerError.NonUniqueElementError` if
            two or more students have the same EDUID (should be impossible)
     - Returns: A new `StudentManager` object
     */
    public init() throws {
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            allStudents = try moc.fetch(Student.getAllStudents())
        } catch {
            allStudents = [Student]()
        }
            eduid2StudentIndex = StudentManager.getMapFromStudents(students: allStudents)
        
        if !ensureUnique() {
            throw StudentManagerError.NonUniqueElementError
        }
    }
    
    /**
     Creates a new `StudentManager` object from a list of students.
     
     - Throws:`StudentManagerError.NonUniqueElementError` if
     two or more students have the same EDUID
     
     - Returns: A new `StudentManager` object
     */
    public init(students: [Student]) throws {
        allStudents = students
        eduid2StudentIndex = StudentManager.getMapFromStudents(students: students)
        
        if !ensureUnique() {
            throw StudentManagerError.NonUniqueElementError
        }
    }
    
    /**
     Given a file name with an EDUID, retrieves the student to whom that EDUID belongs if
     one is found.
     
     - Returns: the student matching the EDUID in the file name if one exists.
     */
    public func getStudentFromFileName(fileName: String) -> Student? {
        if let eduid: Int = StudentManager.getEduidFromString(s: fileName) {
            return getStudentForEduid(eduid: eduid)
        }
        return nil
    }
    
    /**
     Finds an EDUID in a given string, and returns it as an `Int`if it exists.
     
     - Parameters:
         - s: the given string
     
     - Returns: the EDUID in a string if one is found
     */
    public static func getEduidFromString(s: String) -> Int? {
        if let eduidRange = s.range(of: #"[0-9]{7,9}"#, options: .regularExpression) {
            return Int(s[eduidRange])
        }
        return nil
    }
    
    /**
     Returns the student for a given EDUID.
     
     - Parameters:
         - eduid: the EDUID of a student in the data base
     
     - Returns: a `Student` object from the data base with the corresponding EDUID
     */
    public func getStudentForEduid(eduid: Int) -> Student? {
        if let eduid = eduid2StudentIndex[eduid] {
            return allStudents[eduid]
        }
        return nil
    }
    
    /// Adds a student to the data base.
    public mutating func addStudent(student: Student) {
        // TODO: Update the database
        if getStudentForEduid(eduid: student.eduid) != nil {
            let index = eduid2StudentIndex[student.eduid]!
            allStudents[index] = student
        } else {
            allStudents.append(student)
            eduid2StudentIndex[student.eduid] = self.count - 1
        }
    }
    
    /// Updates the data base to match the contents of a given `Student` array
    public mutating func update(students: [Student]) throws {
        allStudents = students
        eduid2StudentIndex = StudentManager.getMapFromStudents(students: students)
        
        if !ensureUnique() {
            throw StudentManagerError.NonUniqueElementError
        }
    }
    
    /// Returns all students as an array of `Student` objects.
    public func getAllStudents() -> [Student] {
        return allStudents
    }
    
    /**
     Given an array of `Student` objects, creates a `Dictionary` object that maps
     each student's EDUID to their position in the internal array.
     
     - Parameters:
         - students: an array of `Student` objects
     
     - Returns: a map of EDUIDs to student indices in the internal array
     */
    private static func getMapFromStudents(students: [Student]) -> Dictionary<Int, Int> {
        var map = Dictionary<Int, Int>()
        for (index, student) in students.enumerated() {
            map[student.eduid] = index
        }
        return map
    }
    
    /// Creates a map of EDUIDs to their corresponding `Student` objects.
    public func getStudentMap() -> Dictionary<Int, Student> {
        var map = Dictionary<Int, Student>()
        
        for student in allStudents {
            map[student.eduid] = student
        }
        
        return map
    }
    
    /// Clears all the students from the data base.
    public mutating func clearAll() {
        try! self.update(students: [Student]())
    }
    
    /// Ensures that all elements in the internal array are unique.
    public func ensureUnique() -> Bool {
        var eduidSet = Set<Int>()
        for student in allStudents {
            if eduidSet.contains(student.eduid) {
                return false
            }
            eduidSet.insert(student.eduid)
        }
        return true
    }
    
    /// Gets a student at an index location in the internal array.
    public func atIndex(index: Int) -> Student {
        return self.allStudents[index]
    }
}
