//
//  MetarsParserTests.swift
//  CaelumTests
//
//  Created by Mark Descalzo on 7/15/25.
//

import XCTest
@testable import Caelum

final class MetarsParserTests: XCTestCase {
  var parser: MetarsParser!
  
  override func setUp() {
    super.setUp()
    parser = MetarsParser()
  }
  
  override func tearDown() {
    parser = nil
    super.tearDown()
  }
  
  
  func testParsingSingleMetar() throws {
    // Sample XML containing a single METAR
    let xml = """
        <response>
          <data num_results="1">
            <METAR>
              <station_id>KBOI</station_id>
              <observation_time>2025-07-11T18:15:00Z</observation_time>
              <temp_c>25.0</temp_c>
              <wind_dir_degrees>180</wind_dir_degrees>
              <raw_text>KBOI 111815Z 18010KT 10SM CLR 25/10 A2992 RMK AO2</raw_text>
            </METAR>
          </data>
        </response>
        """
    let data = Data(xml.utf8)
    
    // Act
    let result = try parser.parse(data: data)
    
    // Assert
    XCTAssertEqual(result.count, 1)
    let metar = result[0]
    XCTAssertEqual(metar.stationID, "KBOI")
    XCTAssertEqual(metar.temperature, "25.0")
    XCTAssertEqual(metar.wind, "180")
    XCTAssertEqual(metar.rawText, "KBOI 111815Z 18010KT 10SM CLR 25/10 A2992 RMK AO2")
    
    let expectedDate = ISO8601DateFormatter().date(from: "2025-07-11T18:15:00Z")
    XCTAssertEqual(metar.observationTime, expectedDate)
  }
  
  func testMultipleMetarsParsedCorrectly() {
    let xml = """
    <response>
      <METAR>
        <station_id>KBOI</station_id>
        <observation_time>2025-07-14T18:15:00Z</observation_time>
        <temp_c>25.5</temp_c>
        <wind_dir_degrees>270</wind_dir_degrees>
        <raw_text>Raw 1</raw_text>
      </METAR>
      <METAR>
        <station_id>KBOI</station_id>
        <observation_time>2025-07-14T19:15:00Z</observation_time>
        <temp_c>26.5</temp_c>
        <wind_dir_degrees>280</wind_dir_degrees>
        <raw_text>Raw 2</raw_text>
      </METAR>
    </response>
    """
    let data = Data(xml.utf8)
    let result = try? parser.parse(data: data)
    XCTAssertEqual(result?.count, 2)
  }

  
  func testEmptyDataThrows() {
    let emptyData = Data()
    
    XCTAssertThrowsError(try parser.parse(data: emptyData)) { error in
      XCTAssertEqual(error as? AviationDataServiceError, .emptyResponse)
    }
  }
  
  func testInvalidXMLThrows() {
    let badData = Data("<not><valid></xml>".utf8)
    
    XCTAssertThrowsError(try parser.parse(data: badData)) { error in
      XCTAssertEqual(error as? AviationDataServiceError, .xmlParseFailure)
    }
  }
  
  func testParsingEmptyDataThrowsError() {
    let emptyData = Data()
    
    XCTAssertThrowsError(try parser.parse(data: emptyData)) { error in
      XCTAssertEqual(error as? AviationDataServiceError, .emptyResponse)
    }
  }
  
  func testMalformedXMLThrowsParseError() {
    let malformed = "<METAR><station_id>KLAX</station_id>" // Not closed properly
    
    XCTAssertThrowsError(try parser.parse(data: malformed.data(using: .utf8)!)) { error in
      XCTAssertEqual(error as? AviationDataServiceError, .xmlParseFailure)
    }
  }
  
  func testMetarMissingFieldsIsSkipped() {
    let xml = """
    <response>
      <METAR>
        <station_id>KBOI</station_id>
        <!-- Missing observation_time -->
        <raw_text>Some raw data</raw_text>
      </METAR>
    </response>
    """
    let data = Data(xml.utf8)
    let result = try? parser.parse(data: data)
    XCTAssertEqual(result?.count, 0)
  }

  func testInvalidObservationTimeSkipsMetar() {
    let xml = """
    <response>
      <METAR>
        <station_id>KBOI</station_id>
        <observation_time>BadDate</observation_time>
        <raw_text>Raw</raw_text>
      </METAR>
    </response>
    """
    let data = Data(xml.utf8)
    let result = try? parser.parse(data: data)
    XCTAssertEqual(result?.count, 0)
  }
}
