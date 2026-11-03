//
//  DataService.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

import Foundation

protocol DataServiceProtocol {
  func load<T: Decodable>(_ filename: String) -> T
}

final class JSONService: DataServiceProtocol {
  func load<T: Decodable>(_ filename: String) -> T {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
      fatalError("Missing \(filename).json")
    }
    let data = try! Data(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try! decoder.decode(T.self, from: data)
  }
}
