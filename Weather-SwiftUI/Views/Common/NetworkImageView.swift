//
//  NetworkImageView.swift
//  Weather-SwiftUI
//
//  Created by Joshua Homann on 9/11/20.
//

import Combine
import Nuke
import SwiftUI

struct NetworkImage: View {
  @State private var image: UIImage?
  private let download = CurrentValueSubject<ImageTask?, Never>(nil)
  private let url: URL?
  private let background: UIColor
  init(url: URL? = nil, placeHolder: UIImage? = nil, background: UIColor = .gray) {
    self.url = url
    self.background = background
    image = placeHolder

  }
  var body: some View {
    SwiftUI.Image(uiImage: self.image ?? UIImage())
      .resizable()
      .scaledToFill()
      .onAppear {
        self.download.send(self.url.map { url in
          ImagePipeline.shared.loadImage(with: url, completion:  { result in
            switch result {
            case let .success(response): self.image = response.image
            case let .failure(error): print(error)
            }
          })
        })
      }
  }
}

