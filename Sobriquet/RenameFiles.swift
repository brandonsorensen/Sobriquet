//
//  sort-files.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Cocoa
import Foundation

enum RenameError: Error {
    case NoOutputComponentError
    case UnknownOutputComponentError
    case RepeatedComponentError
    case ComponentIterationError
    case FileNotFoundError
}
