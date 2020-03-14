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
    let DEFAULT_ENROLLMENT = "default-enrollment"
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
//        let contentView = ContentView()
        let managedObjectContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contentView = ContentView().environment(\.managedObjectContext, managedObjectContext)

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
        let container = NSPersistentContainer(name: "EnrollmentModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //  You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
   
}

extension NSManagedObjectContext {
    var coreDataIsEmpty: Bool {
        let appDelegate = (NSApplication.shared.delegate) as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        do {
           let request: NSFetchRequest<Student> = NSFetchRequest(entityName: "Student")
           let count  = try managedObjectContext.count(for: request)
           return count == 0
        } catch {
           return true
        }
    }
}
