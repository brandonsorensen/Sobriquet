//
//  openFileDialog.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import AppKit
import SwiftUI

func createFileDialog() -> NSOpenPanel {
    let fileDialog = NSOpenPanel()

    fileDialog.prompt = "Select path"
    fileDialog.worksWhenModal = true
    fileDialog.canChooseDirectories = true
    fileDialog.canChooseFiles = false
    fileDialog.canCreateDirectories = true
    fileDialog.allowsMultipleSelection = false
    
    return fileDialog
}
