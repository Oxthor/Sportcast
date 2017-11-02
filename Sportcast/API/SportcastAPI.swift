//
//  SportcastWeatherAPI.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 7/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import UIKit
import CoreLocation

typealias ForecastJSON = [String: Any]

final class SportcastAPI: NSObject {
  
  static var shared = SportcastAPI()
  
  // Generate url of type: http://api.openweathermap.org/data/2.5/forecast?id=524901&APPID={APIKEY}
  // Call API with that url
  // Return error or success with forecast information
  
  func getWeather(range: WeatherRange, type: OpenWeatherAPISearchType, value: Any, completion: @escaping (Result<[ForecastJSON], APIError>) -> ()) {
    guard let urlString = type.url(baseURL: K.API.BaseURL, value: value, range: range, apiKey: K.API.Key) else {
      completion(.failure(.invalidParameter))
      return
    }
    
    print("API CALL URL: \(urlString)")
    
    guard let url = URL(string: urlString) else {
      completion(.failure(.invalidURL(urlString)))
      return
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else {
        completion(.failure(.networkError(error!)))
        return
      }
      
      guard let response = response as? HTTPURLResponse else {
        completion(.failure(.noResponseError))
        return
      }
      
      if response.statusCode != 200 {
        completion(.failure(.unexpectedStatusCode(statusCode: response.statusCode)))
        return
      }
      
      guard let data = data else {
        completion(.failure(.noDataError))
        return
      }
      
      do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? ForecastJSON {
          switch range {
          case .current: completion(.success([json]))
          case .threeHours:
            if let list = json["list"] as? [ForecastJSON] {
              completion(.success(list))
            }
          }
        } else {
          completion(.failure(.noDataError))
        }
      } catch let error {
        completion(.failure(.jsonParseError(error)))
        return
      }
      }.resume()
  }
}
