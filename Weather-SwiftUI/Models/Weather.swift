//
//  Weather.swift
//  Weather-SwiftUI
//
//  Created by Joshua Homann on 9/11/20.
//

import Foundation

// MARK: - WeatherLocation
struct WeatherLocation: Codable {
  var properties: WeatherLocationProperties
  // MARK: - WeatherLocationProperties
  struct WeatherLocationProperties: Codable {
    var forecastHourly: URL
  }
}

// MARK: - ForecastWrapper
struct Forecast: Codable {
  var properties: Properties

  // MARK: - Properties
  struct Properties: Codable {
    var periods: [Period]
  }

  // MARK: - Period
  struct Period: Codable {
    var number: Int
    var name: String
    var startTime: Date
    var isDaytime: Bool
    var temperature: Int
    var temperatureUnit: String
    var windSpeed: String
    var windDirection: String
    var icon: URL
    var shortForecast: String
    var detailedForecast: String
  }

}


