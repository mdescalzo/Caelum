//
//  ContentView.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//

import SwiftUI

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @StateObject var service: AviationDataService
  @State private var station = "KMAN"

  @FetchRequest(
      sortDescriptors: [NSSortDescriptor(keyPath: \AirportEntity.id, ascending: true)],
      animation: .default
  )
  private var airports: FetchedResults<AirportEntity>
  
  var body: some View {
    NavigationView {
      VStack {
        TextField("Enter station (e.g. KMAN)", text: $station)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()
        
        Button("Fetch METAR") {
          Task {
            await service.fetchAndStoreMetars(for: station)
          }
        }
        .padding()
        Button("DELETE ALL") {
          PersistenceController.shared.deleteAllAirports(in: viewContext)
        }
        .padding()
        
        AirportListView(airports: airports)

      }
      .navigationTitle("Flight Info")
      .alert("Error", isPresented: Binding<Bool>(
        get: { service.error != nil },
        set: { if !$0 { service.error = nil } }
      )) {
        Button("OK", role: .cancel) { }
      } message: {
        Text(service.error?.localizedDescription ?? "Unknown error")
      }
    }
  }
}

//#Preview {
//  ContentView()
//}
