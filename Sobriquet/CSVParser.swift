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
                }
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
