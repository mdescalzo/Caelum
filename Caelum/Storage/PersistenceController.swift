//
//  PersistenceController.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//

import CoreData

final class PersistenceController {
  static let shared = PersistenceController()
  
  let container: NSPersistentContainer
  
  private init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "LocalDataStore")
    
    if inMemory {
      container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    }
    
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("❌ Unresolved error loading Core Data store: \(error), \(error.userInfo)")
      }
    }
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
  }
  
  func newBackgroundContext() -> NSManagedObjectContext {
    let context = container.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return context
  }
  
  func deleteAllAirports(in context: NSManagedObjectContext) {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AirportEntity.fetchRequest()

    do {
      if let airports = try context.fetch(fetchRequest) as? [AirportEntity] {
        
        airports.forEach { context.delete($0) }
        
        try context.save()
      }
    } catch {
      print("❌ Failed to delete all airports: \(error)")
    }
  }

  
}
