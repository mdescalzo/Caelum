//
//  MetarViewModel.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/15/25.
//

import Foundation

struct MetarViewModel: Identifiable {
  let id: Date
  
  let rawText: String
  let temperature: String
  let wind: String
  let observationTime: String
  
  init(from entity: MetarEntity) {
    self.id = entity.observationTime ?? Date.distantPast
    self.rawText = entity.rawText ?? "N/A"
    self.temperature = String(format: "%.1f", entity.temperature)
    self.wind = String(format: "%.1f", entity.wind)
    self.observationTime = entity.observationTime?.formatted() ?? "Unknown"
  }
}

