//
//  CoreDataStack.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 26/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
  static var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  static var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Sportcast")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  // MARK: - Core Data Saving support
  static func saveContext () {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  

}
