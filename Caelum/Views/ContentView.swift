//
//  ContentView.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var service = WeatherService()
  @State private var station = "KSFO"
  
  var body: some View {
    NavigationView {
      VStack {
        TextField("Enter station (e.g. KSFO)", text: $station)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()
        
        Button("Fetch METAR") {
          Task {
            await service.fetchMETARs(for: station)
          }
        }
        
        List(service.metars, id: \.observationTime) { metar in
          VStack(alignment: .leading) {
            Text("Station: \(metar.stationID)")
            Text("Time: \(metar.observationTime)")
            Text("Temp: \(metar.temperature) ºC")
            Text("Wind: \(metar.wind)º")
            Text("Raw: \(metar.rawText)")
          }
        }
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

#Preview {
  ContentView()
}
