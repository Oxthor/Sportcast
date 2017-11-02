//
//  ForecastRowController.swift
//  Watch Extension
//
//  Created by Alexandre Rubio on 28/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import WatchKit

class ForecastRowController: NSObject {
  @IBOutlet var timeLabel: WKInterfaceLabel!
  @IBOutlet var rainLabel: WKInterfaceLabel!
  @IBOutlet var temperatureLabel: WKInterfaceLabel!
  @IBOutlet var windLabel: WKInterfaceLabel!
  
  var forecast: Forecast? {
    didSet {
      guard let forecast = forecast else { return }
      
      timeLabel.setText(forecast.time)
      rainLabel.setText(forecast.precipitation)
      temperatureLabel.setText(forecast.temperature)
      windLabel.setText(forecast.wind)
    }
  }
}
