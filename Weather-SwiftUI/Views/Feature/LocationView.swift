//
//  LocationView.swift
//  Weather-SwiftUI
//
//  Created by Joshua Homann on 9/12/20.
//

import SwiftUI
import Combine
import MapKit

enum SearchState<Value> {
  case awaitingSearch, searching, loaded(value: Value), empty, error
}

final class LocationViewModel: ObservableObject {
  @Published private(set) var searchResults: [MKMapItem] = []
  @Published var searchTerm = ""
  private var subscriptions = Set<AnyCancellable>()
  init(mapService: MapServiceProtocol) {
    $searchTerm
      .debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
      .removeDuplicates()
      .map { term -> AnyPublisher<[MKMapItem], Never> in
        term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          ? Just([]).eraseToAnyPublisher()
          : mapService
            .search(for: term)
            .replaceError(with: [])
            .eraseToAnyPublisher()
      }
      .switchToLatest()
      .receive(on: DispatchQueue.main)
      .assign(to: \.searchResults, on: self)
      .store(in: &subscriptions)
  }
}

struct LocationViewCell: View {
  let item: MKMapItem
  @EnvironmentObject private var viewModelFactory: ViewModelFactory
  var body: some View {
    NavigationLink(destination: ForecastView(
      name: item.placemark.name ?? "",
      viewModel: viewModelFactory.makeForecastViewModel(
        latitude: item.placemark.location?.coordinate.latitude ?? 0,
        longitude: item.placemark.location?.coordinate.longitude ?? 0
      )
    )) {
      VStack(alignment: .leading) {
        Text(item.name ?? "").font(.headline)
        Text(item.placemark.title ?? "")
      }
    }
  }
}

struct LocationView: View {
  @ObservedObject var viewModel: LocationViewModel
  @EnvironmentObject private var viewModelFactory: ViewModelFactory
  var body: some View {
    List {
      SearchBar(searchTerm: $viewModel.searchTerm)
      ForEach(viewModel.searchResults, id: \.name) { item in
        LocationViewCell(item: item)
      }
    }
    .navigationBarTitle("Location", displayMode: .inline)
  }
}
