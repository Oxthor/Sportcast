//
//  Result.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 8/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

enum Result<T, E: Swift.Error> {
  case success(T)
  case failure(E)
}
