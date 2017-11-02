//
//  Managed.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 26/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import CoreData


protocol Managed: class, NSFetchRequestResult {
  static var entityName: String { get }
  static var defaultSortDescriptors: [NSSortDescriptor] { get }
}


extension Managed {
  static var defaultSortDescriptors: [NSSortDescriptor] { return [] }
  
  static var sortedFetchRequest: NSFetchRequest<Self> {
    let request = NSFetchRequest<Self>(entityName: entityName)
    request.sortDescriptors = defaultSortDescriptors
    return request
  }
  
  public static func sortedFetchRequest(with predicate: NSPredicate) -> NSFetchRequest<Self> {
    let request = sortedFetchRequest
    request.predicate = predicate
    return request
  }
}


extension Managed where Self: NSManagedObject {
  static var entityName: String { return String(describing: self) }
  
  static func insertObject(in context: NSManagedObjectContext) -> Self {
    guard let obj = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? Self else { fatalError("Wrong object type") }
    return obj
  }
  
  static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self] {
    let request = NSFetchRequest<Self>(entityName: Self.entityName)
    configurationBlock(request)
    return try! context.fetch(request)
  }
  
  static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> ()) -> Self {
    guard let object = findOrFetch(in: context, matching: predicate) else {
      let newObject: Self = Self.insertObject(in: context)
      configure(newObject)
      return newObject
    }
    return object
  }
  
  static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
    guard let object = materializedObject(in: context, matching: predicate) else {
      return fetch(in: context) { request in
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        }.first
    }
    return object
  }
  
  static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
    for object in context.registeredObjects where !object.isFault {
      guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
      return result
    }
    return nil
  }
}

