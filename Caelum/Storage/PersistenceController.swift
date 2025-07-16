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
  
  init(inMemory: Bool = false) {
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
  
  func deleteAllAirports(in context: NSManagedObjectContext) async throws {
    let backgroundContext = newBackgroundContext()
    
    try await backgroundContext.perform {
      let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AirportEntity.fetchRequest()
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      deleteRequest.resultType = .resultTypeObjectIDs
      
      let result = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
      if let objectIDs = result?.result as? [NSManagedObjectID] {
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.container.viewContext])
        print("✅ Deleted \(objectIDs.count) airports")
      }
    }
  }
  
  func deleteAllMetars(in context: NSManagedObjectContext) async throws {
    let backgroundContext = newBackgroundContext()
    
    try await backgroundContext.perform {
      let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MetarEntity.fetchRequest()
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      deleteRequest.resultType = .resultTypeObjectIDs
      
      let result = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
      if let objectIDs = result?.result as? [NSManagedObjectID] {
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.container.viewContext])
        print("✅ Deleted \(objectIDs.count) METARs")
      }
    }
  }
}
