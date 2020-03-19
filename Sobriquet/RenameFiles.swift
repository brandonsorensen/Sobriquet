//
//  sort-files.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Cocoa
import Foundation

enum PATH_STATUS {
    case SUCCESS
    case NOTADIR
    case NOTEXIST
}

func renameFilesInDir(inputPath: String, outputPath: String, outputFormat: String) {
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: inputPath)
        for file in files {
            print(file)
        }
    } catch {
        print(error)
    }
}

func renameFile(inputPath: String, outputPath: String, outputFormat: String) {
    switch checkPath(path: inputPath) {
    case .SUCCESS:
        
        print("success")
    case .NOTADIR:
        print("not a directory")
    case .NOTEXIST:
        print("does not exist")
    }
}

func checkPath(path: String) -> PATH_STATUS {
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
