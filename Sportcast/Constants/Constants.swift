//
//  Constants.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 7/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import UIKit

struct K {
  struct API {
    static let BaseURL = "http://api.openweathermap.org/data/2.5/"
    static let IconsURL = "http://openweathermap.org/img/w/"
    static let Key = "a2c7f703335498af3936a2e8f4dd44e4"
  }
  
  struct Entities {
    static let Forecast = "Forecast"
  }
  
  struct Cells {
    static let ForecastCell = "ForecastCell"
    static let DateSectionHeader = "DateSectionHeader"
  }
  
  struct Watch {
    static let Group = "group.sportcast.forecast"
    
    struct UserDefaults {
      static let Precipitation = "precipitation"
      static let Temperature = "temperature"
      static let Wind = "wind"
      static let Time = "time"
    }
  }
  
  struct Values {
    static let WatchForecastItems = 5
  }
}
