//
//  NSManagedObjectContext+Square1.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 26/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
  func saveOrRollback() -> Bool {
    do {
      try save()
      return true
    } catch {
      rollback()
      return false
    }
  }
  
  func performChanges(block: @escaping () -> ()) {
    perform {
      block()
      _ = self.saveOrRollback()
    }
  }
}
