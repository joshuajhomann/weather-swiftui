//
//  MapService.swift
//  Weather-SwiftUI
//
//  Created by Joshua Homann on 9/12/20.
//

import Foundation
import MapKit
import Combine


protocol MapServiceProtocol {
  func search(for term: String) -> Future<[MKMapItem], Error>
}

final class MapService: MapServiceProtocol {
  func search(for term: String) -> Future<[MKMapItem], Error> {
    .init { promise in
      let searchRequest = MKLocalSearch.Request()
      searchRequest.pointOfInterestFilter = .init(including: [.airport, .amusementPark, .aquarium, .beach, .campground, .marina, .stadium, .university, .zoo])
      searchRequest.naturalLanguageQuery = term
      MKLocalSearch(request: searchRequest).start { response, error in
        promise(error.map(Result.failure(_:)) ?? .success(response?.mapItems ?? []))
      }
    }
  }
}
