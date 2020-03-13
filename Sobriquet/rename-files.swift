//
//  sort-files.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Foundation

enum PATH_STATUS {
    case SUCCESS
    case NOTADIR
    case NOTEXIST
}



func readCSV(csvURL: String, encoding: String.Encoding, delimiter: String = ",", inBundle: Bool = true) -> [Student]? {
    // Load the CSV file and parse it
    var items = [Student]()
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
                    
                    let student = Student(eduid: Int(fields[0])!, lastName: fields[1],
                                          firstName: fields[2],
                                          middleName: fields[3].isEmpty ? nil : fields[3])
                    items.append(student)
                }
            }
            
        } catch {
            print(error)
        }
    }
    return items
}

struct Student {
    var eduid: Int
    var lastName: String
    var firstName: String
    var middleName: String?
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
