//
//  AirportListView.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//

import SwiftUI

struct AirportListView: View {
 
  let airports: FetchedResults<AirportEntity>
  
  @State private var expandedAirports: Set<String> = []
  
  var body: some View {
    
    List {
      ForEach(airports, id: \.id) { airport in
        Section {
          AirportDisclosureView(
            airport: AirportViewModel(from: airport),
            isExpanded: expandedAirports.contains(airport.id ?? "")) { expanded in
              guard let id = airport.id else { return }
              if expanded {
                expandedAirports.insert(id)
              } else {
                expandedAirports.remove(id)
              }
            }
        }
      }
    }
  }
}



//#Preview {
//    AirportListView()
//}
