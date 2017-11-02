//
//  APIError.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 7/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import UIKit

public enum APIError: Error {
  case invalidParameter
  case invalidURL(String)
  case networkError(Error)
  case noDataError
  case noResponseError
  case unexpectedStatusCode(statusCode: Int)
  case jsonParseError(Error)
  
  public var name:String {
    switch self {
    case .invalidParameter: return "Invalid parameter"
    case .invalidURL: return "Invalid URL"
    case .networkError: return "Network error"
    case .noDataError: return "No data found"
    case .noResponseError: return "No response found"
    case .unexpectedStatusCode: return "Unexpected status code"
    case .jsonParseError: return "JSON parse error"
    }
  }
}

extension APIError: CustomStringConvertible {
  
  public var description:String {
    switch self {
    case .invalidParameter: return "\(name)"
    case .invalidURL(let url): return "\(name): \(url)"
    case .networkError(let error): return "\(name): \(error.localizedDescription)"
    case .noDataError: return "\(name)"
    case .noResponseError: return "\(name)"
    case .unexpectedStatusCode(let statusCode): return "\(name): \(statusCode)"
    case .jsonParseError(let error): return "\(name): \(error.localizedDescription)"
    }
  }
}
