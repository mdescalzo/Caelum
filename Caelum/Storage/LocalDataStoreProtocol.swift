//
//  LocalDataStoreProtocol.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//

protocol LocalDataStore {
  func fetchAirport(id: String) -> AirportEntity?
  func fetchAllAirports() -> [AirportEntity]
  func saveMetars(_ metars: [Metar], for airportID: String) throws
}

