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
  
  @MainActor @Published var isFetching: Bool = false
  
  private let backgroundContext: NSManagedObjectContext
  private let parser = MetarsParser()
  
  init(container: NSPersistentContainer) {
    // use a background context so we don’t block UI
    self.backgroundContext = container.newBackgroundContext()
    self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
  }
  
  @MainActor
  func fetchAndStoreMetars(for station: String) async {
    isFetching = true
    let urlString = "https://aviationweather.gov/api/data/metar?ids=\(station)&format=xml&hours=1"
    guard let url = URL(string: urlString) else {
      error = AviationDataServiceError.invalidURL
      return
    }
    
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      print(data)
      let metars = try parser.parse(data: data)
      try await backgroundContext.perform {
        for data in metars {
          guard data.stationID.uppercased() == station.uppercased() else { continue }
          let airport = self.fetchOrCreateAirport(with: data.stationID, context: self.backgroundContext)
          airport.lastUpdated = Date()
          
          let metar = self.fetchOrCreateMetar(with: data.observationTime, context: self.backgroundContext)
          metar.rawText = data.rawText
          metar.temperature = Float(data.temperature) ?? 0
          metar.observationTime = data.observationTime
          metar.wind = Float(data.wind) ?? 0
          metar.airport = airport
        }
        if self.backgroundContext.hasChanges {
          try self.backgroundContext.save()
        } else {
          throw AviationDataServiceError.noResultsFound(for: station)
        }
      }
    } catch {
      self.error = error
    }
    isFetching = false
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
  
  private func fetchOrCreateMetar(with observationTime: Date, context: NSManagedObjectContext) -> MetarEntity {
    let request: NSFetchRequest<MetarEntity> = MetarEntity.fetchRequest()
    request.predicate = NSPredicate(format: "observationTime == %@", observationTime as CVarArg)
    if let existing = try? context.fetch(request).first {
      return existing
    }
    let newMetar = MetarEntity(context: context)
    newMetar.observationTime = observationTime
    return newMetar
  }
  
}

// MARK: - Error handling
enum AviationDataServiceError: Error, LocalizedError, Equatable {
  case noResultsFound(for: String)
  case invalidURL
  case networkFailure(Error)
  case xmlParseFailure
  case emptyResponse
  
  var errorDescription: String? {
    switch self {
    case .noResultsFound(let input):
      return "No results found for \(input)"
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
  
  static func == (lhs: AviationDataServiceError, rhs: AviationDataServiceError) -> Bool {
    switch (lhs, rhs) {
    case (.noResultsFound(for: let a), .noResultsFound(for: let b)):
      return a == b
    case (.invalidURL, .invalidURL):
      return true
    case (.xmlParseFailure, .xmlParseFailure):
      return true
    case (.emptyResponse, .emptyResponse):
      return true
    case (.networkFailure(_), .networkFailure(_)):
      return true
    default:
      return false
    }
  }
}

