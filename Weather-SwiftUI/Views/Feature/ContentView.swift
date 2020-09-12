//
//  ContentView.swift
//  Weather-SwiftUI
//
//  Created by Joshua Homann on 9/11/20.
//

import SwiftUI
import Combine
import MapKit

struct ContentView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @EnvironmentObject private var viewModelFactory: ViewModelFactory
  var body: some View {
    switch horizontalSizeClass {
    case .compact:
      NavigationView {
        LocationView(viewModel: viewModelFactory.makeLocationViewModel())
      }.navigationViewStyle(StackNavigationViewStyle())
    default:
      NavigationView {
        LocationView(viewModel: viewModelFactory.makeLocationViewModel())
      }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
  }
}

