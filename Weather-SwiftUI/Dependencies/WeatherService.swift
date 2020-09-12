//
//  WeatherService.swift
//  Weather-SwiftUI
//
//  Created by Joshua Homann on 9/12/20.
//

import Foundation
import Combine

protocol WeatherServiceProtocol {
  func getForecast(latitude: Double, longitude: Double) -> AnyPublisher<[Forecast.Period], Error>
}

final class WeatherService: WeatherServiceProtocol {
  func getForecast(latitude: Double, longitude: Double) -> AnyPublisher<[Forecast.Period], Error> {
    guard let url = URL(string: "https://api.weather.gov/points/\(latitude),\(longitude)") else {
      return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return URLSession.shared
      .dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: WeatherLocation.self, decoder: decoder)
      .map { location -> AnyPublisher<Data, Never> in
        URLSession.shared
          .dataTaskPublisher(for: location.properties.forecastHourly)
          .map(\.data)
          .replaceError(with: Data())
          .eraseToAnyPublisher()
      }
      .switchToLatest()
      .decode(type: Forecast.self, decoder: decoder)
      .map(\.properties.periods)
      .catch { error -> AnyPublisher<[Forecast.Period], Error> in
        print(error)
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
  }
}
