//
//  Untitled.swift
//  Caelum
//
//  Created by Mark Descalzo on 7/16/25.
//

import XCTest
import CoreData
@testable import Caelum

final class AviationDataServiceTests: XCTestCase {
  var controller: PersistenceController!
  var service: AviationDataService!
  
  override func setUpWithError() throws {
    do {
      try super.setUpWithError()
      controller = PersistenceController(inMemory: true)
      service = AviationDataService(container: controller.container)
    } catch {
      XCTFail("Setup failed: \(error)")
      throw error
    }
  }
  
  override func tearDownWithError() throws {
    do {
      controller = nil
      service = nil
      try super.tearDownWithError()
    }catch {
      XCTFail("Teardown failed: \(error)")
      throw error
    }
  }
  
  func testFetchAndStoreMetars_savesToCoreData() async throws {
    let testData = try XCTUnwrap(TestResources.loadData(named: "TestMetars", withExtension: "xml"))
    URLProtocolMock.testData = testData

    try await service.fetchAndStoreMetars(for: "KMAN")

    let fetchRequest: NSFetchRequest<AirportEntity> = AirportEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@", "KMAN")
    
    let results = try controller.container.viewContext.fetch(fetchRequest)
    XCTAssertEqual(results.count, 1, "Should find one AirportEntity for KMAN")
    XCTAssertNotNil(results.first?.lastUpdated, "Airport should have lastUpdated date")

    let metars = results.first?.metars as? Set<MetarEntity>
    XCTAssertNotNil(metars)
    XCTAssertGreaterThan(metars?.count ?? 0, 0, "Should have at least one MetarEntity associated")
  }

}

enum TestResources {
  static func loadData(named name: String, withExtension ext: String) -> Data? {
    let bundle = Bundle(for: AviationDataServiceTests.self)
    guard let url = bundle.url(forResource: name, withExtension: ext) else { return nil }
    return try? Data(contentsOf: url)
  }
}


final class URLProtocolMock: URLProtocol {
  static var testData: Data?
  
  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  
  override func startLoading() {
    if let data = Self.testData {
      self.client?.urlProtocol(self, didLoad: data)
    }
    self.client?.urlProtocolDidFinishLoading(self)
  }
  
  override func stopLoading() {}
}
