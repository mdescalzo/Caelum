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
