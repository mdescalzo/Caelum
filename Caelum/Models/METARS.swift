//
//  METARS.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//

import Foundation

struct Metar {
  let stationID: String
  let observationTime: Date
  let temperature: String
  let wind: String
  let rawText: String
}

// For use with api fetch
struct MetarDTO {
    let stationID: String
    let observationTime: Date
    let temperature: String
    let wind: String
    let rawText: String
}


//struct MetarData {
//  let rawText: String
//  let observationTime: Date
//  let temperature: Float
//  let wind: Float
//}
