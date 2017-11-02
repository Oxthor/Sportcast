//
//  ForecastInterfaceController.swift
//  Watch Extension
//
//  Created by Alexandre Rubio on 28/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class ForecastInterfaceController: WKInterfaceController {
  @IBOutlet var forecastTable: WKInterfaceTable!
  @IBOutlet var noForecastLabel: WKInterfaceLabel!
  
  var forecasts: [Forecast]? {
    didSet {
      guard let forecasts = forecasts else { return }
      forecastTable.setNumberOfRows(forecasts.count, withRowType: K.Rows.Forecast)
      
      for index in 0..<forecastTable.numberOfRows {
        guard let controller = forecastTable.rowController(at: index) as? ForecastRowController else { continue }
        controller.forecast = forecasts[index]
      }
    }
  }
  
  var session: WCSession? {
    didSet {
      if let session = session {
        session.delegate = self
        session.activate()
      }
    }
  }
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    session = WCSession.default
  }
}

extension ForecastInterfaceController: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print(error)
      return
    }
    
    print(activationState)
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    guard let times = message[K.Connectivity.Time] as? [String],
      let winds = message[K.Connectivity.Wind] as? [String],
      let temperatures = message[K.Connectivity.Temperature] as? [String],
      let precipitations = message[K.Connectivity.Precipitation] as? [String] else { return }
    
    var forecasts = [Forecast]()
    for index in 0..<times.count {
      forecasts.append(Forecast(time: times[index], temperature: temperatures[index], wind: winds[index], precipitation: precipitations[index]))
    }
    
    if !forecasts.isEmpty {
      DispatchQueue.main.async {
        self.noForecastLabel.setHidden(true)
        self.forecastTable.setHidden(false)
      }
      
      self.forecasts = forecasts
    }
  }
}

struct Forecast {
  var time: String
  var temperature: String
  var wind: String
  var precipitation: String
}
