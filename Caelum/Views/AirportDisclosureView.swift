//
//  AirportDisclosureView.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/14/25.
//

import SwiftUI

struct AirportDisclosureView: View {
  let airport: AirportEntity
  let isExpanded: Bool
  let toggleExpanded: (Bool) -> Void
  
  var body: some View {
    DisclosureGroup(
      isExpanded: Binding(
        get: { isExpanded },
        set: { toggleExpanded($0) }
      ),
      content: {
        ForEach(metarArray, id:\.observationTime) { metar in
          VStack(alignment: .leading) {
            Text("Time: \(formatted(metar.observationTime))")
            Text("Temp: \(formatted(metar.temperature))")
            Text("Wind: \(formatted(metar.wind))")
            Text(metar.rawText ?? "")
          }
          .padding(.vertical, 4)
        }
      },
      label: {
        Text(airport.id ?? "Unknown")
          .font(.headline)
      }
    )
  }
  
  private var metarArray: [MetarEntity] {
    let set = airport.metars as? Set<MetarEntity> ?? []
    return set.sorted {
      ($0.observationTime ?? .distantPast) > ($1.observationTime ?? .distantPast)
    }
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
      df.dateFormat = "HH:mm E, d MM y"
      return df.string(from: value)
    } else {
      return "-"
    }
  }
  
}




//#Preview {
//    AirportDisclosureView()
//}
