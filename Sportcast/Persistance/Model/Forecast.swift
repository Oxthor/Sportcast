//
//  Forecast.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 26/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import Foundation
import CoreData

final class Forecast: NSManagedObject, Managed {
  @NSManaged public var city: String?
  @NSManaged public var date: Double
  @NSManaged public var humidity: Float
  @NSManaged public var id: Int32
  @NSManaged public var info: String?
  @NSManaged public var precipitation: Float
  @NSManaged public var pressure: Float
  @NSManaged public var temperature: Float
  @NSManaged public var windDegrees: Float
  @NSManaged public var windSpeed: Float
  @NSManaged public var icon: String?
  @NSManaged public var current: Bool
  
  static var defaultSortDescriptors: [NSSortDescriptor] { return [
    NSSortDescriptor(key: "date", ascending: true)
    ]
  }
}

extension Forecast {
  func populate(from json: ForecastJSON) {
    // WIND
    if let windObject = json["wind"] as? [String: Any] {
      if let deg = windObject["deg"] as? Float {
        self.windDegrees = deg
      }
      if let speed = windObject["speed"] as? Float {
        self.windSpeed = speed
      }
    }
    
    // MAIN
    if let main = json["main"] as? [String: Any] {
      if let humidity = main["humidity"] as? Float {
        self.humidity = humidity
      }
      
      if let pressure = main["pressure"] as? Float {
        self.pressure = pressure
      }
      
      if let temperature = main["temp"] as? Float {
        self.temperature = temperature
      }
    }
    
    // RAIN
    if let rain = json["rain"] as? [String: Any] {
      if let rainInfo = rain["3h"] as? Float {
        self.precipitation = rainInfo
      }
    }
    
    // WEATHER
    if let weatherArray = json["weather"] as? [Any] {
      if let weather = weatherArray.first as? [String: Any] {
        if let desc = weather["description"] as? String {
          self.info = desc
        }
        
        if let icon = weather["icon"] as? String {
          self.icon = "\(K.API.IconsURL)\(icon).png"
        }
      }
    }
    
    // DATE
    if let date = json["dt"] as? Double {
      self.date = date
      self.id = Int32(date)
    }
  }
  
  static func create(with json: ForecastJSON) -> Forecast? {
    let context = CoreDataStack.context
    let predicate = NSPredicate(format: "id == %d", json["dt"] as! Int32)

    let forecast = Forecast.findOrCreate(in: context, matching: predicate) { (forecast) in
      forecast.populate(from: json)
    }
    
    return forecast
  }
  
  static func deleteAllBefore(date: Date) {
    let predicate = NSPredicate(format: "date < %f", date.timeIntervalSince1970)
    
    let oldForecasts = Forecast.fetch(in: CoreDataStack.context) { (request) in
      request.predicate = predicate
    }
    
    CoreDataStack.context.performChanges {
      _ = oldForecasts.map { CoreDataStack.context.delete($0) }
    }
  }

  @objc var mediumDate: String {
    let date = Date(timeIntervalSince1970: self.date)
    return date.string(withDateStyle: .medium)
  }
  
  @objc var time: String {
    let date = Date(timeIntervalSince1970: self.date)
    return date.string(withTimeStyle: .short)
  }
  
  var temperatureFormatted: String {
    let temperature = Measurement(value: Double(self.temperature), unit: UnitTemperature.kelvin)
    let formatter = MeasurementFormatter()
    formatter.numberFormatter.maximumFractionDigits = 0
    
    return formatter.string(from: temperature)
  }
  
  var windSpeedFormatted: String {
    let windSpeed = Measurement(value: Double(self.windSpeed), unit: UnitSpeed.kilometersPerHour)
    let formatter = MeasurementFormatter()
    formatter.numberFormatter.maximumFractionDigits = 1
    
    return formatter.string(from: windSpeed)
  }
}
