//
//  CSVParser.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/14/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Foundation

public struct CSVFields {
    var eduid: Int,
    lastName: String,
    firstName: String,
    middleName: String?
}

public class CSVParser {
    
    private static var numFields = 4
    
    private static let lastNameRegex = #"last[ _]+name"#
    
    static func readCSV(csvURL: String, encoding: String.Encoding, delimiter: String = ",",
                        inBundle: Bool = true) throws -> [CSVFields]? {
        
        // Load the CSV file and parse it
        var entries = [CSVFields]()
        var lines: [String]
        var fields: [String]
        var path = csvURL

        if inBundle {
            if let inBundlePath = Bundle.main.path(forResource: csvURL, ofType: "csv") {
                path = inBundlePath
            }
        }
            
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            lines = data.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() {
                if line.isEmpty { continue }
                
                fields = line.components(separatedBy: delimiter)
                if fields.count != CSVParser.numFields { throw ParserError.MalformedCSV }
                if index == 0 &&
                    fields[0].range(of: lastNameRegex,
                                    options: [.caseInsensitive, .regularExpression]) != nil { continue }  // Skip header
                
                // Checks if all strings are empty and skips iteration if true
                guard fields.first(where: { !$0.isEmpty }) != nil else {
                    continue
                }
                
                let hasMiddle = !fields[2].isEmpty

                guard let eduid = Int(fields[3]) else {
                    throw ParserError.MalformedCSV
                }
            
                entries.append(
                    CSVFields(
                        eduid: eduid, lastName: fields[0],
                        firstName: fields[1],
                        middleName: hasMiddle ? fields[2] : nil
                    )
                )
            }
        } catch {
            throw ParserError.MalformedCSV
        }
        return entries
    }
    
    enum ParserError: Error {
        case MalformedCSV
        case FileNotFound
        case Unknown
    }
}
