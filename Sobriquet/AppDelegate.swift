//
//  AppDelegate.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let DEFAULT_ENROLLMENT = "default-enrollment-03-2020"


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.title = "Sobriquet"
        window.styleMask.remove([ .resizable ])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "StudentModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

}

func parseCSV (contentsOfURL: NSURL, encoding: String.Encoding, error: NSErrorPointer, delimiter: String = ",") ->
    [(eduid: String, lastName:String, firstName: String, middleName: String)]? {
    // Load the CSV file and parse it
    var items: [(eduid: String, lastName:String, firstName: String, middleName: String)]?

    //if let content = String(contentsOfURL: contentsOfURL, encoding: encoding, error: error) {
    if let content = try? String(contentsOf: contentsOfURL as URL, encoding: encoding) {
        items = []
        let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]

        for line in lines {
            var values:[String] = []
            if !line.isEmpty {
                values = line.components(separatedBy: delimiter)

                // Put the values into the tuple and add it to the items array
                let item = (eduid: values[0], lastName: values[1], firstName: values[2], middleName: values[3])
                items?.append(item)
            }
        }
    }

    return items
}

