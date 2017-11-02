//
//  WeatherRange.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 26/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import Foundation

enum WeatherRange {
  case current
  case threeHours
}

extension WeatherRange {
  var endpoint: String {
    switch self {
    case .current: return "weather"
    case .threeHours: return "forecast"
    }
  }
}
