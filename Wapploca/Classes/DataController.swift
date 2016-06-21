//
//  DataController.swift
//  Pods
//
//  Created by gabmarfer on 09/06/16.
//
//

import Foundation
import CoreData

class DataController {
    static let modelName = "Wapploca"
    static let entityTagName = "Tag"
    
    var managedObjectContext: NSManagedObjectContext
    
    init() {
        let bundle = NSBundle(forClass: DataController.self)
        guard let modelURL = bundle.URLForResource(DataController.modelName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        // The managed object model for the application. It is a fatal error for the application 
        // not to be able to find and load its model
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex - 1]
            /* The directory the application uses to store the Core Data store file. This code uses a file named
                Wapploca.sqlite in the application's document directory
            */
            let storeURL = docURL.URLByAppendingPathComponent(DataController.modelName + ".sqlite")
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType,
                                                   configuration: nil,
                                                   URL: storeURL,
                                                   options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    private func p_save() {
        do {
            try managedObjectContext.save()
            print("Saved objects to BBDD")
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    private func p_deleteAllRecords() {
        let fetchRequest = NSFetchRequest(entityName: DataController.entityTagName)
        if #available(iOS 9.0, *) {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.executeRequest(deleteRequest)
                print("Delete all tag records")
            } catch let error as NSError {
                print(error)
            }
        } else {
            // Fallback on earlier versions
            print("Method not available on earlier versions than 9.0")
        }
    }
    
    func fetchTranslationForKey(_ key: String) -> String {
        var translationFetch = NSFetchRequest(entityName: DataController.entityTagName)
        translationFetch.predicate = NSPredicate(format: "name like[cd] %@", key)
        do {
            let fetchedTags = try managedObjectContext.executeFetchRequest(translationFetch) as? [TagMO]
            guard fetchedTags?.count > 0 else {
                return key
            }
            
            guard let translation = fetchedTags?.first!.translation! else {
                return key
            }
            
            return translation
        } catch {
            print("Failed to fetch translation for key: \(key)")
            return key
        }
    }
    
    func saveTags(tagsDict: [String: String]) {
        let entityDescription = NSEntityDescription.entityForName(DataController.entityTagName, inManagedObjectContext: managedObjectContext)
        for (key, value) in tagsDict {
            let tag = TagMO(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
            tag.name = key
            tag.translation = value
        }
        p_deleteAllRecords()
        p_save()
    }
}