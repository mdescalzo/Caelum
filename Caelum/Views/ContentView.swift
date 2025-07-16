//
//  ContentView.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//

import SwiftUI

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext

  let service: AviationDataService

  @State private var station = "KMAN"
  @State private var isFetching: Bool = false
  @State private var isDeleting: Bool = false
  @State private var errors: [Error] = []
  
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

        FetchButton(action: {
          performFetch(for: station)
        }, isLoading: $isFetching)
        .padding()
        
        Button("DELETE ALL") {
          performDelete()
        }
        .disabled(isDeleting)
        .padding()
        
        AirportListView(airports: airports)

      }
      .navigationTitle("Flight Info")
      .alert("Error", isPresented: Binding<Bool>(
        get: { errors.count > 0 },
        set: { if !$0, !errors.isEmpty { errors.removeFirst() } }
      )) {
        Button("OK", role: .cancel) { }
      } message: {
        Text(errors.first?.localizedDescription ?? "Unknown error")
      }
    }
  }
  
  func performFetch(for station: String) {
    Task {
      isFetching = true
      do {
        try await service.fetchAndStoreMetars(for: station.uppercased())
      } catch {
        errors.append(error)
      }
      isFetching = false
    }
  }
  
  func performDelete() {
    Task {
      isDeleting = true
      do {
        try await PersistenceController.shared.deleteAllAirports(in: viewContext)
        try await PersistenceController.shared.deleteAllMetars(in: viewContext)
      } catch {
        errors.append(error)
      }
      isDeleting = false
    }
  }
  
  struct FetchButton: View {
      let action: () -> Void
      @Binding var isLoading: Bool

      var body: some View {
          Button(action: {
              action()
          }) {
              HStack {
                  if isLoading {
                      ProgressView()
                  }
                  Text(isLoading ? "Fetching..." : "Fetch METAR")
              }
          }
          .disabled(isLoading)
          .padding()
      }
  }
}

//#Preview {
//  ContentView()
//}
