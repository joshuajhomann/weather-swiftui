//
//  Dependencies.swift
//  Weather-SwiftUI
//
//  Created by Joshua Homann on 9/12/20.
//

import SwiftUI
import Combine

final class ViewModelFactory: ObservableObject {
  private let mapService: MapServiceProtocol
  private let weatherService: WeatherServiceProtocol
  init() {
    mapService = MapService()
    weatherService = WeatherService()
  }
  func makeLocationViewModel() -> LocationViewModel{
    .init(mapService: mapService)
  }
  func makeForecastViewModel(latitude: Double, longitude: Double) -> ForecastViewModel{
    .init(weatherService: weatherService, latitude: latitude, longitude: longitude)
  }
}

