//
//  AppDelegate.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-11.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseCore

/*public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

extension DarwinNotification.Name {
    private static let appIsExtension = Bundle.main.bundlePath.hasSuffix(".appex")

    /// The relevant DarwinNotification name to observe when the managed object context has been saved in an external process.
    static var didSaveManagedObjectContextExternally: DarwinNotification.Name {
        if appIsExtension {
            return appDidSaveManagedObjectContext
        } else {
            return extensionDidSaveManagedObjectContext
        }
    }

    /// The notification to post when a managed object context has been saved and stored to the persistent store.
    static var didSaveManagedObjectContextLocally: DarwinNotification.Name {
        if appIsExtension {
            return extensionDidSaveManagedObjectContext
        } else {
            return appDidSaveManagedObjectContext
        }
    }

    /// Notification to be posted when the shared Core Data database has been saved to disk from an extension. Posting this notification between processes can help us fetching new changes when needed.
    private static var extensionDidSaveManagedObjectContext: DarwinNotification.Name {
        return DarwinNotification.Name("com.wetransfer.app.extension-did-save")
    }

    /// Notification to be posted when the shared Core Data database has been saved to disk from the app. Posting this notification between processes can help us fetching new changes when needed.
    private static var appDidSaveManagedObjectContext: DarwinNotification.Name {
        return DarwinNotification.Name("com.wetransfer.app.app-did-save")
    }
}

extension NSPersistentContainer {
    // Configure change event handling from external processes.
    func observeAppExtensionDataChanges() {
        DarwinNotificationCenter.shared.addObserver(self, for: .didSaveManagedObjectContextExternally, using: { [weak self] (_) in
            // Since the viewContext is our root context that's directly connected to the persistent store, we need to update our viewContext.
            self?.viewContext.perform {
                self?.viewContextDidSaveExternally()
            }
        })
    }
}

extension NSPersistentContainer {

    /// Called when a certain managed object context has been saved from an external process. It should also be called on the context's queue.
    func viewContextDidSaveExternally() {
        // `refreshAllObjects` only refreshes objects from which the cache is invalid. With a staleness intervall of -1 the cache never invalidates.
        // We set the `stalenessInterval` to 0 to make sure that changes in the app extension get processed correctly.
        viewContext.stalenessInterval = 0
        viewContext.refreshAllObjects()
        viewContext.stalenessInterval = -1
    }
}*/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    // MARK: -- THE ONE
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "schema")
        
        
        /*let container = NSPersistentContainer(name: "schema")
        let storeURL = URL.storeURL(for: "group.dittskolschema", databaseName: "Coyote")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]*/
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    /*
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Profile")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()*/

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        //let context = CoreDataStack.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

