//
//  WeatherService.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//

import Foundation

class WeatherService: NSObject, ObservableObject {
  
  @Published private(set) var metars: [Metar] = []
  @Published var error: WeatherServiceError? = nil
  
  func fetchMETARs(for station: String) async {
    let urlString = "https://aviationweather.gov/api/data/metar?ids=\(station)&format=xml&hours=1"

    
    guard let url = URL(string: urlString) else {
      fatalError("Invalid METAR URL: \(urlString)")
    }
    
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      
      let parsedMetars = try await Task.detached(priority: .userInitiated) {
        return try MetarsParser().parse(data: data)
      }.value
      
      await MainActor.run {
        self.metars = parsedMetars
      }
    } catch let error as WeatherServiceError {
      await MainActor.run {
        self.error = error
      }
    } catch {
      await MainActor.run {
        self.error = .networkFailure(error)
      }
    }
  }
}


// MARK: - Error handling
enum WeatherServiceError: Error, LocalizedError {
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
