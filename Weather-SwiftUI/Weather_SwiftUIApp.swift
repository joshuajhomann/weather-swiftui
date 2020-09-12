//
//  Weather_SwiftUIApp.swift
//  Weather-SwiftUI
//
//  Created by Joshua Homann on 9/11/20.
//

import SwiftUI

@main
struct Weather_SwiftUIApp: App {
  @StateObject private var viewModelFactory = ViewModelFactory()
  var body: some Scene {
    WindowGroup {
      ContentView().environmentObject(viewModelFactory)
    }
  }
}
