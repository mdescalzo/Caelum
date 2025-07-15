//
//  AirportViewModel.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/15/25.
//

import Foundation

struct AirportViewModel: Identifiable {
  let id: String
  
  let lastUpdated: String
  let metars: [MetarViewModel]
  
  init(from entity: AirportEntity) {
    self.id = (entity.id ?? "Unknown").uppercased()
    
    if let date = entity.lastUpdated {
      self.lastUpdated = date.formatted(date: .abbreviated, time: .shortened)
    } else {
      self.lastUpdated = "—"
    }
    
    // Sort by observation time descending
    if let metarSet = entity.metars as? Set<MetarEntity> {
      self.metars = metarSet
        .sorted { ($0.observationTime ?? .distantPast) > ($1.observationTime ?? .distantPast) }
        .map { MetarViewModel(from: $0) }
    } else {
      self.metars = []
    }
  }
}
