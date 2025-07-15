//
//  MetarsParser.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/11/25.
//
import Foundation

private struct PartialMetar {
  var stationID: String = ""
  var observationTime: String = ""
  var temperature: String = ""
  var wind: String = ""
  var rawText: String = ""
  
  func metar() -> Metar? {
    guard let observationTimeDate = ISO8601DateFormatter().date(from: observationTime) else { return nil }
    return Metar(stationID: stationID,
                 observationTime: observationTimeDate,
                 temperature: temperature,
                 wind: wind,
                 rawText: rawText)
  }
}

final class MetarsParser: NSObject, XMLParserDelegate {
  private var metars: [Metar] = []
  
  private var currentMetar: PartialMetar?
  
  private var currentElement = ""
  private var characterBuffer = ""
  
  func parse(data: Data) throws -> [Metar] {
    guard !data.isEmpty else {
      throw AviationDataServiceError.emptyResponse
    }
    
    let parser = XMLParser(data: data)
    parser.delegate = self
    
    guard parser.parse() else {
      throw AviationDataServiceError.xmlParseFailure
    }
    
    return metars
  }
  
  // MARK: - XMLParserDelegate
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
    currentElement = elementName
    characterBuffer = ""
    
    if elementName == "METAR" {
      currentMetar = PartialMetar()
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    characterBuffer += string
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    let trimmed = characterBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
    
    switch elementName {
    case "station_id": currentMetar?.stationID = trimmed
    case "observation_time": currentMetar?.observationTime = trimmed
    case "temp_c": currentMetar?.temperature = trimmed
    case "raw_text": currentMetar?.rawText = trimmed
    case "wind_dir_degrees": currentMetar?.wind = trimmed
    case "METAR":
      guard let metar = currentMetar?.metar() else { return }
      metars.append(metar)
      currentMetar = nil
    default:
      break
    }
  }
}
