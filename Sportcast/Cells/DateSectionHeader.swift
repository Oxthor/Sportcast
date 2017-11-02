//
//  DateSectionHeader.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 8/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import UIKit

class DateSectionHeader: UITableViewHeaderFooterView {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  func configure(with title: String) {
    titleLabel.text = title
  }
}
