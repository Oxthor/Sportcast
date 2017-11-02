//
//  Sportcast+Date.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 28/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import Foundation

extension Date {
  func string(withDateStyle style: DateFormatter.Style) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = style
    
    return dateFormatter.string(from: self)
  }
  
  func string(withTimeStyle style: DateFormatter.Style) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = style
    
    return dateFormatter.string(from: self)
  }
}
