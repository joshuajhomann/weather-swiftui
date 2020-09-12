//
//  ForeCastView.swift
//  Weather-SwiftUI
//
//  Created by Joshua Homann on 9/12/20.
//

import SwiftUI
import Combine

final class ForecastViewModel: ObservableObject {
  struct DailyForecast: Identifiable {
    var id: String { day }
    var day: String
    var forecasts: [HourlyForecast]
  }
  struct HourlyForecast: CustomStringConvertible, Identifiable {
    var id: Int
    var day: String
    var time: String
    var isDaytime: Bool
    var temperature: String
    var wind: String
    var icon: URL
    var description: String
    private static let dayFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "EEEE"
      return formatter
    }()
    private static let timeFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.timeStyle = .short
      return formatter
    }()
    init(period: Forecast.Period) {
      id = period.number
      day = Self.dayFormatter.string(from: period.startTime)
      time = Self.timeFormatter.string(from: period.startTime)
      isDaytime = period.isDaytime
      temperature = "\(period.temperature) \(period.temperatureUnit)"
      wind = "Wind \(period.windSpeed) \(period.windDirection)"
      icon = period.icon
      description = period.shortForecast
    }
  }
  @Published private(set) var forecasts: [DailyForecast] = []
  private var subscriptions = Set<AnyCancellable>()
  init(weatherService: WeatherServiceProtocol, latitude: Double, longitude: Double) {
    weatherService
      .getForecast(latitude: latitude, longitude: longitude)
      .replaceError(with: [])
      .map { periods in
        let forecasts = periods.map(HourlyForecast.init(period:))
        let grouped = [String: [HourlyForecast]](grouping: forecasts, by: \.day)
        return grouped
          .keys
          .sorted { (grouped[$0]?[0].id ?? 0) < (grouped[$1]?[0].id ?? 0) }
          .compactMap { key in grouped[key].map { DailyForecast(day: key, forecasts: $0) } }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.forecasts, on: self)
      .store(in: &subscriptions)
  }
}

struct ForecastView: View {
  let name: String
  @ObservedObject var viewModel: ForecastViewModel
  @EnvironmentObject private var viewModelFactory: ViewModelFactory
  var body: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.flexible())]) {
        ForEach(viewModel.forecasts) { row in
          VStack(alignment: .leading) {
            Text(row.id).font(.largeTitle)
            ScrollView(.horizontal) {
              LazyHGrid(rows: [GridItem(.flexible())]) {
                ForEach(row.forecasts) { forecast in
                  ZStack {
                    NetworkImage(url: forecast.icon)
                      .overlay(
                        LinearGradient(
                          gradient: Gradient(colors: [
                            Color.black.opacity(0.25),
                            Color.clear,
                            Color.black.opacity(0.25),
                          ]),
                          startPoint: .top,
                          endPoint: .bottom
                        )
                      )
                      .clipShape(RoundedRectangle(cornerRadius: 24))

                  VStack {
                    Text(forecast.time).font(.title)
                    Text(forecast.temperature).font(.largeTitle)
                    Spacer()
                    Text(forecast.wind).font(.callout)
                    Text(forecast.description)
                  }.padding()
                  }
                  .foregroundColor(Color.white)
                  .padding()
                  .frame(width: 200)
                  .clipShape(RoundedRectangle(cornerRadius: 12))
                }
              }
              .frame(height: 200)
            }
          }
          .padding()
        }
      }
    }
    .navigationBarTitle("Forecast for \(name)", displayMode: .inline)
  }
}
