//
//  OpenWeatherAPISearchType.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 26/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import Foundation
import CoreLocation

enum OpenWeatherAPISearchType {
  case coordinate
  case cityID
  case cityName
  case zipCode
  
  func url(baseURL: String, value: Any, range: WeatherRange, apiKey: String) -> String? {
    switch self {
    case .cityID: return "\(baseURL)\(range.endpoint)?id=\(value)&APPID=\(apiKey)"
    case .cityName: return "\(baseURL)\(range.endpoint)?q=\(value)&APPID=\(apiKey)"
    case .coordinate:
      guard let coordinate = value as? CLLocationCoordinate2D else { return nil }
      let lat = coordinate.latitude
      let lon = coordinate.longitude
      return "\(baseURL)\(range.endpoint)?lat=\(lat)&lon=\(lon)&APPID=\(apiKey)"
    case .zipCode: return "\(baseURL)\(range.endpoint)?zip=\(value)&APPID=\(apiKey)"
    }
  }
}
