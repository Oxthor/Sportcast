//
//  ForecastCell.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 8/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import UIKit

class ForecastCell: UITableViewCell {
  
  @IBOutlet weak var windLabel: UILabel!
  @IBOutlet weak var precipitationLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var forecastImageView: UIImageView!
  @IBOutlet weak var containerView: UIView!
  
  func configure(with forecast: Forecast) {
    precipitationLabel.text = forecast.precipitation.description
    temperatureLabel.text = forecast.temperatureFormatted
    windLabel.text = forecast.windSpeedFormatted
    timeLabel.text = forecast.time
    
    if let icon = forecast.icon {
      forecastImageView.downloadedFrom(link: icon)
    }
    
    containerView.layer.cornerRadius = 5.0
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOpacity = 0.1
    containerView.layer.shadowOffset = CGSize.zero
    containerView.layer.shadowRadius = 5
  }
}
