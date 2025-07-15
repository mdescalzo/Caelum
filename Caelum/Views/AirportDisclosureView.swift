//
//  AirportDisclosureView.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/14/25.
//

import SwiftUI

struct AirportDisclosureView: View {
  let airport: AirportViewModel
  let isExpanded: Bool
  let toggleExpanded: (Bool) -> Void
  
  var body: some View {
    DisclosureGroup(
      isExpanded: Binding(
        get: { isExpanded },
        set: { toggleExpanded($0) }
      ),
      content: {
        ForEach(airport.metars, id:\.observationTime) { metar in
          VStack(alignment: .leading) {
            Text("Time: \(metar.observationTime)")
            Text("Temp: \(metar.temperature)")
            Text("Wind: \(metar.wind)")
            Text(metar.rawText)
          }
          .padding(.vertical, 4)
        }
      },
      label: {
        HStack {
          Text(airport.id)
            .font(.headline)
          Spacer()
          Text(airport.lastUpdated)
            .font(.subheadline)
        }
      }
    )
  }

  private func formatted(_ value: Float?) -> String {
    if let value = value {
      return String(format: "%.1f", value)
    } else {
      return "-"
    }
  }
  
  private func formatted(_ value: Date?) -> String {
    if let value = value {
      let df = DateFormatter()
      df.dateStyle = .medium
      df.timeStyle = .medium
      
//      df.dateFormat = "HH:mm E, d MM y"
      
      return df.string(from: value)
    } else {
      return "-"
    }
  }
  
}




//#Preview {
//    AirportDisclosureView()
//}
