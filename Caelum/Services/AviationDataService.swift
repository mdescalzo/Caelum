//
//  AviationDataController.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//

import Foundation
import CoreData

final class AviationDataService: NSObject, ObservableObject {
  @MainActor @Published var error: Error?

  private let backgroundContext: NSManagedObjectContext
  private let parser = MetarsParser()
  
  init(container: NSPersistentContainer) {
    // use a background context so we don’t block UI
    self.backgroundContext = container.newBackgroundContext()
    self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
  }
  
  @MainActor
  func fetchAndStoreMetars(for station: String) async {
    let urlString = "https://aviationweather.gov/api/data/metar?ids=\(station)&format=xml&hours=1"
    guard let url = URL(string: urlString) else {
      fatalError("Invalid METAR URL: \(urlString)")
    }

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      
      let metars = try parser.parse(data: data)
print(metars)
      try await backgroundContext.perform {
        let airport = self.fetchOrCreateAirport(with: station, context: self.backgroundContext)
        
        let existingMetars: [Date: MetarEntity] = (airport.metars as? Set<MetarEntity> ?? [])
          .reduce(into: [:]) { dict, metar in
            if let time = metar.observationTime {
              dict[time] = metar
            }
          }
        for data in metars {
          let metar = existingMetars[data.observationTime] ?? MetarEntity(context: self.backgroundContext)
          metar.rawText = data.rawText
          metar.temperature = Float(data.temperature) ?? 0
          metar.observationTime = data.observationTime
          metar.wind = Float(data.wind) ?? 0
          metar.airport = airport
        }
        try self.backgroundContext.save()
      }
    } catch {
      self.error = error
//      fatalError("Failed to fetch or save METARs for \(station): \(error)")
    }
  }
  
  private func fetchOrCreateAirport(with id: String, context: NSManagedObjectContext) -> AirportEntity {
    let request: NSFetchRequest<AirportEntity> = AirportEntity.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id)
    if let existing = try? context.fetch(request).first {
      return existing
    }
    let newAirport = AirportEntity(context: context)
    newAirport.id = id
    return newAirport
  }
  
}

// MARK: - Error handling
enum AviationDataServiceError: Error, LocalizedError {
  case invalidURL
  case networkFailure(Error)
  case xmlParseFailure
  case emptyResponse
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Internal error: malformed URL."
    case .networkFailure(let err):
      return "Network error: \(err.localizedDescription)"
    case .xmlParseFailure:
      return "Could not read weather data."
    case .emptyResponse:
      return "No data received from weather server."
    }
  }
}

