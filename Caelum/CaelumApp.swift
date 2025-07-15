//
//  CaelumApp.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//

import SwiftUI

@main
struct CaelumApp: App {
  let persistenceController = PersistenceController.shared
  
  var body: some Scene {
    WindowGroup {
      ContentView(service: AviationDataService(container: PersistenceController.shared.container))
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
