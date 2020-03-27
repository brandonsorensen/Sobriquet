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
                if !line.isEmpty {
                    fields = line.components(separatedBy: delimiter)
                    if index == 0 &&
                        fields[0].range(of: lastNameRegex,
                                        options: [.caseInsensitive, .regularExpression]) != nil { continue }  // Skip header
                    let hasMiddle: Bool = !fields[2].isEmpty
                    entries.append(
                        CSVFields(
                            eduid: Int(fields[3])!, lastName: fields[0],
                            firstName: fields[1],
                            middleName: hasMiddle ? fields[3] : nil
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
